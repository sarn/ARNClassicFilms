//
//  ARNMovieDBController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieDBController.h"
#import "ARNMovieController.h"
#import "ARNMovie.h"
#import "AFHTTPSessionOperation.h"

@interface ARNMovieDBController ()
    @property (nonatomic, strong) AFHTTPSessionManager *manager;
    @property (nonatomic, strong) dispatch_group_t fetchMovieDataGroup;
    @property (nonatomic, strong) NSOperationQueue *queue;
@end


@implementation ARNMovieDBController

+ (ARNMovieDBController *)sharedInstance {
    static ARNMovieDBController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNMovieDBController alloc] init];
    });
    
    return instance;
}

- (void)fetchMovieDetailsForMovies:(NSArray *)movies withManager:(AFHTTPSessionManager *)manager andCompletionBlock:(void (^)())completion {
    if (movies != nil && [movies count] > 0 && manager != nil) {
        self.manager = manager;

        // To keep track of all the async task we are going to fire we create a dispatch group.
        // With this we can count all the calls and then get informed if the last call is done
        // http://stackoverflow.com/a/32714702/956433
        self.fetchMovieDataGroup = dispatch_group_create();
        
        // the connection to tvdb is too slow, we need a queue and limit the concurrent request
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1; // TODO: increase to 5

        for (id obj in movies) {
            if (obj != nil && [obj isKindOfClass:[ARNMovie class]]) {
                ARNMovie *arnMovie = (ARNMovie *)obj;
                
                dispatch_group_enter(self.fetchMovieDataGroup);
                [self fetchMovieDetailsForMovie:arnMovie];
            }
        }
        
        dispatch_group_notify(self.fetchMovieDataGroup, dispatch_get_main_queue(),^{
            // Do your stuff, everything has finished loading
            if (completion != nil) {
                completion();
            }
        });
    } else {
        if (completion != nil) {
            completion();
        }
    }
}
    
- (void)fetchMovieDetailsForMovie:(ARNMovie *)arnMovie {
    if (arnMovie != nil && [arnMovie.title length] > 0 && [arnMovie.year integerValue] > 0 && self.queue != nil) {
        NSDictionary *parameters = @{@"api_key": @"cde3935be83a0ceff90f530f19931df3",
                                     @"query": arnMovie.title,
                                     @"year": arnMovie.year};
        
        [self.queue addOperation:[AFHTTPSessionOperation operationWithManager:self.manager method:@"GET" URLString:@"http://api.themoviedb.org/3/search/movie" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSDictionary *jsonDict = (NSDictionary *) responseObject;
            
            //NSLog(@"JSON: %@", jsonDict);
            
            NSArray *resultsArray = (NSArray *)[jsonDict objectForKey:@"results"];
            if(resultsArray != nil && [resultsArray count] > 0){
                NSDictionary *resultDict = resultsArray[0];
                
                //NSLog(@"JSON: %@", resultDict);
                //NSLog(@"*****************************");
                //NSLog(@"title: %@", arnMovie.title);
                //NSLog(@"year: %ld", (long)arnMovie.year);
                //NSLog(@"backdrop_path: %@", [resultDict objectForKey:@"backdrop_path"]);
                //NSLog(@"poster_path: %@", [resultDict objectForKey:@"poster_path"]);
                //NSLog(@"overview: %@", [resultDict objectForKey:@"overview"]);
                //NSLog(@"date: %@", [resultDict objectForKey:@"date"]);
                //NSLog(@"title: %@", [resultDict objectForKey:@"title"]);
                
                // fill in the data
                arnMovie.tmdb_id = [[resultDict objectForKey:@"id"] stringValue];
                arnMovie.movie_description = [resultDict objectForKey:@"overview"];
                arnMovie.posterURL = [resultDict objectForKey:@"poster_path"];
                arnMovie.backdropURL = [resultDict objectForKey:@"backdrop_path"];
                
                // save it
                [[ARNMovieController sharedInstance] addMovie:arnMovie];
                NSLog(@"SUCCESS");
            }
            
            dispatch_group_leave(self.fetchMovieDataGroup);
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            if (response.statusCode == 429) {
                // 429 Too Many Requests
                // this api has a rate limit - uuugh
                // so we have to wait for the amount of seconds
                // which are listed in the "retry-after" property
                NSDictionary *headers = response.allHeaderFields;
                id retryAfterId = [headers valueForKey:@"Retry-After"];
                if (retryAfterId != nil && [retryAfterId isKindOfClass:[NSString class]]) {
                    NSInteger retryAfterSeconds = [retryAfterId integerValue];
                    
                    NSLog(@"RETRY: %li", retryAfterSeconds);
                    // wait for retryAfterSeconds
                    [NSTimer scheduledTimerWithTimeInterval:retryAfterSeconds
                                                     target:self
                                                   selector:@selector(retryFetch:)
                                                   userInfo:@{@"arnMovie" : arnMovie}
                                                    repeats:NO];
                } else {
                    dispatch_group_leave(self.fetchMovieDataGroup);
                }
            } else {
                // it's an other error - we just give up then
                NSLog(@"Error: %@", error);
                dispatch_group_leave(self.fetchMovieDataGroup);
            }
        }]];
    } else {
        dispatch_group_leave(self.fetchMovieDataGroup);
    }
}

- (void)retryFetch:(NSTimer *)timer {
    ARNMovie *arnMovie = timer.userInfo[@"arnMovie"];
    [self fetchMovieDetailsForMovie:arnMovie];
}

@end
