//
//  ARNArchiveController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNArchiveController.h"
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

- (void)fetchMovieArchiveForCollection:(NSString *)collection withManager:(AFHTTPSessionManager *)manager {
    [self fetchMovieArchiveForCollection:collection withManager:manager pageNumber:1 andRows:1];
}

- (void)fetchMovieArchiveForCollection:(NSString *)collection withManager:(AFHTTPSessionManager *)manager pageNumber:(NSInteger)page andRows:(NSInteger)rows {
    if([collection length] > 0 && manager != nil){
        NSDictionary *parameters = @{@"q": [NSString stringWithFormat:@"%@(%@)", @"mediatype:(movies) AND collection:", collection],
                                     @"sort": @[@"downloads desc"],
                                     @"rows": @(rows),
                                     @"page": @(page),
                                     @"fl": @[@"identifier", @"title", @"date"],
                                     @"output": @"json"};
        
        [manager GET:@"https://archive.org/advancedsearch.php" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonDict = (NSDictionary *) responseObject;
                
                //NSLog(@"Full JSON: %@", jsonDict);
                
                id responseID = [jsonDict objectForKey:@"response"];
                if (responseID != nil && [responseID isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *responseDict = (NSDictionary *)responseID;
                    
                    // paging logic
                    id numFoundId = [responseDict objectForKey:@"numFound"];
                    if (numFoundId != nil && [numFoundId isKindOfClass:[NSNumber class]]) {
                        NSNumber *numFound = (NSNumber *)numFoundId;
                        
                        // if we did not get the maximum amount af available data
                        // we just start an other call for the total amount
                        if ((page * rows) < [numFound integerValue]) {
                            [self fetchMovieArchiveForCollection:collection withManager:manager pageNumber:1 andRows:[numFound integerValue]];
                        } else {
                            // the data related to the movies
                            id docsId = [responseDict objectForKey:@"docs"];
                            if (docsId != nil && [docsId isKindOfClass:[NSArray class]]) {
                                NSArray *docsArray = (NSArray *)docsId;
                                
                                NSMutableArray *movies = [NSMutableArray array];
                                
                                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
                                
                                for (NSDictionary *movie in docsArray) {
                                    // parse out data we care about
                                    ARNMovie *arnMovie = [ARNMovie new];
                                    
                                    arnMovie.title = [NSString string];
                                    id titleId = [movie objectForKey:@"title"];
                                    if (titleId != nil && [titleId isKindOfClass:[NSString class]]) {
                                        NSString *title = (NSString *)titleId;
                                        if (![title isKindOfClass:[NSNull class]] && [title length] > 0) {
                                            arnMovie.title = title;
                                        }
                                    }
                                    
                                    arnMovie.archive_id = [NSString string];
                                    id idId = [movie objectForKey:@"identifier"];
                                    if (idId != nil && [idId isKindOfClass:[NSString class]]) {
                                        NSString *archiveId = (NSString *)idId;
                                        if (![archiveId isKindOfClass:[NSNull class]] && [archiveId length] > 0) {
                                            arnMovie.archive_id = archiveId;
                                        }
                                    }
                                    
                                    arnMovie.year = 0;
                                    id dateId = [movie objectForKey:@"date"];
                                    if (dateId != nil && [dateId isKindOfClass:[NSString class]]) {
                                        NSString *date = (NSString *)dateId;
                                        if (![date isKindOfClass:[NSNull class]] && [date length] > 0) {
                                            arnMovie.year = @([self getYear:[dateFormatter dateFromString:date]]);
                                        }
                                    }
                                    
                                    // only add the arnMovie if we have all the essentials components available
                                    if ([arnMovie.title length] > 0 && [arnMovie.archive_id length] > 0 && [arnMovie.year integerValue] > 0) {
                                        [movies addObject:arnMovie];
                                    }
                                }
                                
                                // anhance all the movies we collected with additional meta data
                                [self fetchMovieArchiveForMetaDataAboutMovies:movies withManager:manager];
                            }
                        }
                    }
                }
            }
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)fetchMovieArchiveForMetaDataAboutMovies:(NSMutableArray *)movies withManager:(AFHTTPSessionManager *)manager {
    if (movies != nil && [movies count] > 0 && manager != nil) {
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
//                                        NSLog(@"*****************************");
//                                        NSLog(@"FILE FORMAT: %@", [file objectForKey:@"format"]);
                                        
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
                                                            // fill in the name
                                                            arnMovie.source = name;
                                                            
                                                            // fetch the details from the MovieDB
                                                            [[ARNMovieDBController sharedInstance] fetchMovieDetailsForMovie:arnMovie withManager:manager];
                                                        }
                                                    }
                                                }
                                                
                                            }
                                        }
                                    }
                                }
                                
                                
                            }
                        }
                    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                        NSLog(@"Error: %@", error);
                    }];
                }
            }
        }
    }
}

- (NSInteger)getYear:(NSDate *)date
{
    if (date != nil) {
        NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
        return [components year];
    }
    return 0;
}

@end
