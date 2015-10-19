//
//  ARNMovieDBController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieDBController.h"
#import "AppDelegate.h"
#import "Movie.h"


@implementation ARNMovieDBController

+ (ARNMovieDBController *)sharedInstance {
    static ARNMovieDBController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNMovieDBController alloc] init];
    });
    
    return instance;
}

- (void)fetchMovieDetailsForMovie:(ARNMovie *)arnMovie withManager:(AFHTTPSessionManager *)manager {
    if (manager != nil && arnMovie != nil && [arnMovie.title length] > 0 && [arnMovie.year integerValue] > 0) {
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = appDelegate.managedObjectContext;
        if (context != nil) {
            //ARNMovie *arnMovie = (ARNMovie *)collection[0];
            
            // TODO: for the last iteration post the notification (on both the success and the failure block)
            // [[NSNotificationCenter defaultCenter] postNotificationName:@"FetchMovieDataSuccessful" object:self userInfo:nil];
            
            NSDictionary *parameters = @{@"api_key": @"cde3935be83a0ceff90f530f19931df3",
                                         @"query": arnMovie.title,
                                         @"year": arnMovie.year};
            
            
            [manager GET:@"http://api.themoviedb.org/3/search/movie" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                NSDictionary *jsonDict = (NSDictionary *) responseObject;
                
                //NSLog(@"JSON: %@", jsonDict);
                
                NSArray *resultsArray = (NSArray *)[jsonDict objectForKey:@"results"];
                if(resultsArray != nil && [resultsArray count] > 0){
                    NSDictionary *resultDict = resultsArray[0];
                    
                    
                    NSLog(@"JSON: %@", resultDict);
                    NSLog(@"*****************************");
                    
                    NSLog(@"title: %@", arnMovie.title);
                    NSLog(@"year: %ld", (long)arnMovie.year);
                    
                    NSLog(@"backdrop_path: %@", [resultDict objectForKey:@"backdrop_path"]);
                    NSLog(@"poster_path: %@", [resultDict objectForKey:@"poster_path"]);
                    NSLog(@"overview: %@", [resultDict objectForKey:@"overview"]);
                    //NSLog(@"date: %@", [resultDict objectForKey:@"date"]);
                    //NSLog(@"title: %@", [resultDict objectForKey:@"title"]);
                    
                    // fill in the data
                    arnMovie.tmdb_id = [[resultDict objectForKey:@"id"] stringValue];
                    arnMovie.movie_description = [resultDict objectForKey:@"overview"];
                    arnMovie.posterURL = [resultDict objectForKey:@"poster_path"];
                    arnMovie.backdropURL = [resultDict objectForKey:@"backdrop_path"];
                    
                    
                    // only save if we have enough data
                    if ((![arnMovie.title isKindOfClass:[NSNull class]] && [arnMovie.title length] > 0) &&
                        (![arnMovie.posterURL isKindOfClass:[NSNull class]] && [arnMovie.posterURL length] > 0)) {
                        
                        // save it to CoreData
                        Movie *movie = nil;
                        if (![arnMovie.archive_id isKindOfClass:[NSNull class]]) {
                            NSFetchRequest *movieFetchRequest = [[NSFetchRequest alloc] init];
                            movieFetchRequest.entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
                            movieFetchRequest.predicate = [NSPredicate predicateWithFormat:@"archive_id == %@", arnMovie.archive_id];
                            
                            NSArray *result = [context executeFetchRequest:movieFetchRequest error:nil];
                            if(result != nil && [result count] > 0){
                                id obj = [result lastObject];
                                if(obj != nil && [obj isKindOfClass:[Movie class]]){
                                    movie = (Movie *) obj;
                                }
                            }
                        }
                        
                        
                        
                        // create new movie if there is not an existing one
                        if(movie == nil){
                            movie = (Movie *)[NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:context];
                        }
                        
                        // fill/update the data
                        movie.archive_id = (![arnMovie.archive_id isKindOfClass:[NSNull class]] && [arnMovie.archive_id length] > 0) ? arnMovie.archive_id : [NSString string];
                        movie.tmdb_id = (![arnMovie.tmdb_id isKindOfClass:[NSNull class]] && [arnMovie.tmdb_id length] > 0) ? arnMovie.tmdb_id : [NSString string];
                        movie.title = (![arnMovie.title isKindOfClass:[NSNull class]] && [arnMovie.title length] > 0) ? arnMovie.title : [NSString string];
                        movie.year = (![arnMovie.year isKindOfClass:[NSNull class]] && [arnMovie.year integerValue] >= 1800) ? arnMovie.year : @(0);
                        movie.movie_description = (![arnMovie.movie_description isKindOfClass:[NSNull class]] && [arnMovie.movie_description length] > 0) ? arnMovie.movie_description : [NSString string];
                        movie.posterURL = (![arnMovie.posterURL isKindOfClass:[NSNull class]] && [arnMovie.posterURL length] > 0) ? arnMovie.posterURL : [NSString string];
                        movie.backdropURL = (![arnMovie.backdropURL isKindOfClass:[NSNull class]] && [arnMovie.backdropURL length] > 0) ? arnMovie.backdropURL : [NSString string];
                        movie.source = (![arnMovie.source isKindOfClass:[NSNull class]] && [arnMovie.source length] > 0) ? arnMovie.source : [NSString string];
                        
                        [context save:nil];
                        
                        // TODO: replace AFNetworking Image Cache with DSWEbImage to preload all the posters and backdrops in te background to a Disc Cache (and not Ram Cache only like AFNetworking provides)
                        
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                NSLog(@"Error: %@", error);
                
                // TODO: this api has a rate limit - uuugh
                // -> stop the current for loop
                // wait for Retry-after as seconds
                // restart this method with all movie objects with have a refresh date older than 10 minutes
                //
                // more info here: https://www.themoviedb.org/talk/5317af69c3a3685c4a0003b1 && https://www.themoviedb.org/faq/api?language=en
                /*
                 Error: Error Domain=com.alamofire.error.serialization.response Code=-1011 "Request failed: client error (429)" UserInfo={com.alamofire.serialization.response.error.response=<NSHTTPURLResponse: 0x7fc31ae59d60> { URL: http://api.themoviedb.org/3/search/movie?api_key=cde3935be83a0ceff90f530f19931df3&query=Charlie%20Chaplin%27s%20%22The%20Cure%22&year=0 } { status code: 429, headers {
                 "Access-Control-Allow-Origin" = "*";
                 Connection = "keep-alive";
                 "Content-Length" = 95;
                 "Content-Type" = "application/json; charset=utf-8";
                 Date = "Fri, 16 Oct 2015 09:53:58 GMT";
                 "Retry-After" = 8;
                 Server = openresty;
                 } }, NSErrorFailingURLKey=http://api.themoviedb.org/3/search/movie?api_key=cde3935be83a0ceff90f530f19931df3&query=Charlie%20Chaplin%27s%20%22The%20Cure%22&year=0, com.alamofire.serialization.response.error.data=<7b227374 61747573 5f636f64 65223a32 352c2273 74617475 735f6d65 73736167 65223a22 596f7572 20726571 75657374 20636f75 6e742028 34312920 6973206f 76657220 74686520 616c6c6f 77656420 6c696d69 74206f66 2034302e 227d0a>, NSLocalizedDescription=Request failed: client error (429)}
                 
                 */
                
            }];
        }
    }
}

@end
