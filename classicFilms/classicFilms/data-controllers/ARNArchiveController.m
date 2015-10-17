//
//  ARNArchiveController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNArchiveController.h"
#import "AFHTTPSessionManager.h"
#import "ARNMovieDBController.h"
#import "ARNMovie.h"


@implementation ARNArchiveController

+ (ARNArchiveController *)sharedInstance {
    static ARNArchiveController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNArchiveController alloc] init];
    });
    
    return instance;
}

- (void)fetchMovieArchiveForCollection:(NSString *)collection {
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *parameters = @{@"q": @"mediatype:(movies) AND collection:(feature_films)",
                                 @"sort": @[@"downloads desc"],
                                 @"rows": @50,
                                 @"page": @1,
                                 @"output": @"json"};
    
    [manager GET:@"https://archive.org/advancedsearch.php" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSMutableArray *movies = [NSMutableArray array];
        
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        
        NSDictionary *responseDict = (NSDictionary *)[jsonDict objectForKey:@"response"];
        NSArray *moviesArray = (NSArray *)[responseDict objectForKey:@"docs"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        for (NSDictionary *movie in moviesArray) {
            // parse out data we care about
            
            NSLog(@"*****************************");
            
            
            //NSLog(@"title: %@", [movie objectForKey:@"title"]);
            NSLog(@"JSON: %@", movie);
//            NSLog(@"identifier: %@", [movie objectForKey:@"identifier"]);
//            NSLog(@"description: %@", [movie objectForKey:@"description"]);
//            NSLog(@"date: %@", [movie objectForKey:@"date"]);
//            
            
            NSDate *date = [dateFormatter dateFromString:[movie objectForKey:@"date"]];
//            NSLog(@"year: %ld", (long)[self getYear:date]);
            
            
            
            
            ARNMovie *arnMovie = [ARNMovie new];
            arnMovie.title = [movie objectForKey:@"title"];
            arnMovie.archive_id = [movie objectForKey:@"identifier"];
            arnMovie.year = @([self getYear:date]);
            [movies addObject:arnMovie];
            
            
        }
        
        [self fetchMovieArchiveForMetaDataAboutMovies:movies];
        //[[ARNMovieDBController sharedInstance] fetchMovieDetailsForCollection:movies];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];

    // TODO: attribute archive.org and themoviedb.org
    
    // TODO: limit the return values from archive.org to only the stuff we need

}

- (void)fetchMovieArchiveForMetaDataAboutMovies:(NSMutableArray *)movies {
    if (movies != nil && [movies count] > 0) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        //NSMutableArray *fullyFledgedMovies = [NSMutableArray arrayWithCapacity:[movies count]];
        
        for (id obj in movies) {
            if (obj != nil && [obj isKindOfClass:[ARNMovie class]]) {
                ARNMovie *arnMovie = (ARNMovie *)obj;
                if (![arnMovie.archive_id isKindOfClass:[NSNull class]] && [arnMovie.archive_id length] > 0) {
                    
                    NSString *urlToFetch = [NSString stringWithFormat:@"%@%@", @"https://archive.org/metadata/", arnMovie.archive_id];
                    [manager GET:urlToFetch parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                        
                        if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]]) {
                            NSDictionary *jsonDict = (NSDictionary *) responseObject;
                            
                            id filesId = [jsonDict objectForKey:@"files"];
                            if (filesId != nil && [filesId isKindOfClass:[NSArray class]]) {
                                NSArray *files = (NSArray *)filesId;

                                for (id fileId in files) {
                                    if (fileId != nil && [fileId isKindOfClass:[NSDictionary class]]) {
                                        NSDictionary *file = (NSDictionary *)fileId;
                                        
                                        // parse out data we care about
                                        
                                        NSLog(@"*****************************");
                                        
                                        
                                        //NSLog(@"title: %@", [movie objectForKey:@"title"]);
                                        NSLog(@"FILE FORMAT: %@", [file objectForKey:@"format"]);
                                        
                                        id formatId = [file objectForKey:@"format"];
                                        if (formatId != nil && [formatId isKindOfClass:[NSString class]]) {
                                            NSString *format = (NSString *)formatId;
                                            if (![format isKindOfClass:[NSNull class]] && [format length] > 0) {
                                                // check if we have a supported media format
                                                
                                                // TODO: maybe support other formats?
                                                NSRange containsMPEG4 = [format rangeOfString:@"MPEG4" options:NSCaseInsensitiveSearch];
                                                if(containsMPEG4.length > 0)
                                                {
                                                    // is a MPEG4 format -> try to get the file name
                                                    id nameId = [file objectForKey:@"name"];
                                                    if (nameId != nil && [nameId isKindOfClass:[NSString class]]) {
                                                        NSString *name = (NSString *)nameId;
                                                        if (![name isKindOfClass:[NSNull class]] && [name length] > 0) {
                                                            // fill in the name and add it to the fullyFledgedMovies array for further processing
                                                            arnMovie.source = name;
//                                                            [fullyFledgedMovies addObject:arnMovie];
                                                            [[ARNMovieDBController sharedInstance] fetchMovieDetailsForMovie:arnMovie];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                            }
                        }
//                        
                        
                    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                        NSLog(@"Error: %@", error);
                    }];
                    
                    
                } else {
                    // we got a movie object without any archive_id
                    // we can't use such an object and don't add it to the final mutable array
                }
            }
        }
    }
}

- (NSInteger)getYear:(NSDate*)date
{
    if (date != nil) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
        return [components year];
    }
    return 0;
}

@end
