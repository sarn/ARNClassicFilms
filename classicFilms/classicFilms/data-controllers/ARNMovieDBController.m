//
//  ARNMovieDBController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieDBController.h"
#import "AFHTTPSessionManager.h"
#import "ARNMovie.h"

@implementation ARNMovieDBController

+ (ARNMovieDBController *)sharedInstance {
    static ARNMovieDBController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNMovieDBController alloc] init];
    });
    
    return instance;
}

- (void)fetchMovieDetailsForCollection:(NSArray *)collection {
    __block NSArray *movies = [NSArray array];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    for (ARNMovie *arnMovie in collection) {
    //ARNMovie *arnMovie = (ARNMovie *)collection[0];
    
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
                NSLog(@"year: %@", arnMovie.year);
                
                NSLog(@"backdrop_path: %@", [resultDict objectForKey:@"backdrop_path"]);
                NSLog(@"poster_path: %@", [resultDict objectForKey:@"poster_path"]);
                NSLog(@"overview: %@", [resultDict objectForKey:@"overview"]);
                //NSLog(@"date: %@", [resultDict objectForKey:@"date"]);
                //NSLog(@"title: %@", [resultDict objectForKey:@"title"]);
                
                // fill in the data
                arnMovie.tmdb_id = [resultDict objectForKey:@"id"];
                arnMovie.movie_description = [resultDict objectForKey:@"overview"];
                arnMovie.posterURL = [resultDict objectForKey:@"poster_path"];
                arnMovie.backdropURL = [resultDict objectForKey:@"backdrop_path"];
                
                // TODO: save it to CoreData
            }
            
           
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

@end
