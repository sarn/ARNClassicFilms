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

- (void)fetchMovieDetailsForMovies:(NSArray *)movies withManager:(AFHTTPSessionManager *)manager {
    if (movies != nil && [movies count] > 0 && manager != nil) {
        self.manager = manager;
        
        // the connection to tvdb is too slow, we need a queue and limit the concurrent request
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 5;

        for (id obj in movies) {
            if (obj != nil && [obj isKindOfClass:[ARNMovie class]]) {
                ARNMovie *arnMovie = (ARNMovie *)obj;
                [self fetchMovieDetailsForMovie:arnMovie];
            }
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
                
                // fill in the data
                arnMovie.tmdb_id = [[resultDict objectForKey:@"id"] stringValue];
                arnMovie.movie_description = [resultDict objectForKey:@"overview"];
                arnMovie.posterURL = [resultDict objectForKey:@"poster_path"];
                arnMovie.backdropURL = [resultDict objectForKey:@"backdrop_path"];
                
                // save it
                [[ARNMovieController sharedInstance] addMovie:arnMovie];
            } else {
                // we got an empty result back
                // it could be that the search string was bad - let's try some tricks
                
                // '/'
                // e.g. "Five Minutes to Live / AKA Door-to-Door Maniac"
                if ([arnMovie.title containsString:@"/"]) {
                    // split the string into tokens and start fetch for each token
                    NSArray *chunks = [arnMovie.title componentsSeparatedByString:@"/"];
                    for (NSString *chunk in chunks) {
                        ARNMovie *chunkMovie = [arnMovie copy];
                        chunkMovie.title = [chunk stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                        [self fetchMovieDetailsForMovie:chunkMovie];
                    }  
                }
                
                // '(' + ')'
                // e.g. Charlie Chaplin's "Charlott Et Le Mannequin" (Mabel's Married Life)
                if ([arnMovie.title containsString:@"("] && [arnMovie.title containsString:@")"]) {
                    // get the substring between the () and start a new fetch
                    NSError *error = nil;
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(.*?\\)" options:0 error:&error];
                    if(!error) {
                        [regex enumerateMatchesInString:arnMovie.title
                                                options:0
                                                  range:NSMakeRange(0,[arnMovie.title length])
                                             usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                                 if ([result range].length > 2) {
                                                     // range without ()
                                                     NSRange range = NSMakeRange([result range].location + 1, [result range].length - 2);
                                                     
                                                     ARNMovie *chunkMovie = [arnMovie copy];
                                                     chunkMovie.title = [[arnMovie.title substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

                                                     // check if we only got a year number and not a movie title
                                                     // e.g. The Haunted Bedroom (1913), 1913
                                                     // this would actually match to a wrong film on tmdb
                                                     BOOL doTheFetch = YES;
                                                     NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
                                                     if([numberFormatter numberFromString:chunkMovie.title] != nil) {
                                                         NSNumber *titleNumber = [numberFormatter numberFromString:chunkMovie.title];
                                                         if ([arnMovie.year integerValue] == [titleNumber integerValue]) {
                                                             doTheFetch = NO;
                                                         }
                                                     }
                                                     
                                                     if (doTheFetch) {
                                                         [self fetchMovieDetailsForMovie:chunkMovie];
                                                     }
                                                 }
                                             }];
                    }
                }
                
                // " + "
                // e.g. Charlie Chaplin's "Making A Living"
                if ([arnMovie.title containsString:@"\""]) {
                    // get the substring between the "" and start a new fetch
                    NSError *error = nil;
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\\".*?\\\"" options:0 error:&error];
                    if(!error) {
                        [regex enumerateMatchesInString:arnMovie.title
                                                options:0
                                                  range:NSMakeRange(0,[arnMovie.title length])
                                             usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                                 if ([result range].length > 2) {
                                                     // range without ""
                                                     NSRange range = NSMakeRange([result range].location + 1, [result range].length - 2);
                                                     
                                                     ARNMovie *chunkMovie = [arnMovie copy];
                                                     chunkMovie.title = [[arnMovie.title substringWithRange:range] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                     [self fetchMovieDetailsForMovie:chunkMovie];
                                                 }
                                             }];
                    }
                }
                
                // []
                // e.g. In the Park [tinted]
                if ([arnMovie.title containsString:@"["] && [arnMovie.title containsString:@"]"]) {
                    // get the substring without the [text] and start a new fetch
                    NSError *error = nil;
                    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.*?\\]" options:0 error:&error];
                    if(!error) {
                        [regex enumerateMatchesInString:arnMovie.title
                                                options:0
                                                  range:NSMakeRange(0,[arnMovie.title length])
                                             usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
                                                 NSString *stringWithoutBrackets = [arnMovie.title stringByReplacingOccurrencesOfString:[arnMovie.title substringWithRange:[result range]] withString:@""];
                                                 
                                                 ARNMovie *chunkMovie = [arnMovie copy];
                                                 chunkMovie.title = [stringWithoutBrackets stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                                 [self fetchMovieDetailsForMovie:chunkMovie];
                                             }];
                    }
                }
                
            }
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
                    
                    // wait for retryAfterSeconds
                    [NSTimer scheduledTimerWithTimeInterval:retryAfterSeconds
                                                     target:self
                                                   selector:@selector(retryFetch:)
                                                   userInfo:@{@"arnMovie" : arnMovie}
                                                    repeats:NO];
                }
            } else {
                // it's an other error - we just give up then
                NSLog(@"Error: %@", error);
            }
        }]];
    }
}

- (void)retryFetch:(NSTimer *)timer {
    ARNMovie *arnMovie = timer.userInfo[@"arnMovie"];
    [self fetchMovieDetailsForMovie:arnMovie];
}

@end
