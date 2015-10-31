//
//  ARNArchiveController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNArchiveController.h"
#import "ARNMovieController.h"
#import "ARNMovieDBController.h"

@implementation ARNArchiveController

+ (ARNArchiveController *)sharedInstance {
    static ARNArchiveController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNArchiveController alloc] init];
    });
    
    return instance;
}

- (void)fetchForCollection:(NSString *)collection withPageNumber:(NSInteger)page andRows:(NSInteger)rows {
    if([collection length] > 0) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        // prepare data structures for fetch calls
        NSMutableArray *movies = [NSMutableArray array];
        NSDate *fetch_date = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
        
        // create the query parameters
        NSString *dateRestriction =  @" AND date:[null TO 1975]"; // ignore all movies made after 1975
        // -> pre-1976 (I think) without a copyright claim on the print itself is likely ok: https://archive.org/post/1046300/request-how-to-check-copyrights
        NSString *formatRestriction = @" AND format:(MPEG4)"; // TODO: maybe support other formats like "h.264"
        
        // TODO: make sure we only have public domain licenseurl's : licenseurl: "http://creativecommons.org/licenses/publicdomain/"
        
        NSDictionary *parameters = @{@"q": [NSString stringWithFormat:@"%@(%@)%@%@", @"mediatype:(movies) AND collection:", collection, dateRestriction, formatRestriction],
                                     @"sort": @[@"date asc"],
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
                    
                    // the data related to the movies
                    id docsId = [responseDict objectForKey:@"docs"];
                    if (docsId != nil && [docsId isKindOfClass:[NSArray class]]) {
                        NSArray *docsArray = (NSArray *)docsId;
                        NSRegularExpression *iPodRegEx = [NSRegularExpression regularExpressionWithPattern:@".+_ipod.*" options:NSRegularExpressionCaseInsensitive error:nil];
                        
                        for (NSDictionary *movie in docsArray) {
                            // parse out data we care about
                            ARNMovie *arnMovie = [ARNMovie new];
                            arnMovie.collection = collection;
                            arnMovie.date_created = fetch_date;
                            arnMovie.date_updated = fetch_date;
                            arnMovie.page_number = @(page);
                            
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
                                // ignore all movies that end with _ipod
                                if (iPodRegEx != nil) {
                                    NSRange range = NSMakeRange(0, [arnMovie.archive_id length]);
                                    if([iPodRegEx numberOfMatchesInString:arnMovie.archive_id options:0 range:range] <= 0)
                                    {
                                        [movies addObject:arnMovie];
                                    }
                                } else {
                                    // regExp does not function for some reason: just add all movies
                                    [movies addObject:arnMovie];
                                }
                            }
                        }
                    }
                }
            }
            
            if ([movies count] > 0) {
                // enhance all the movies we collected with additional details (posters, descriptions, nice titels, ...)
                [[ARNMovieDBController sharedInstance] fetchMovieDetailsForMovies:movies withManager:manager];
            }
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
        }];
    }
}

- (void)fetchSourceFileForMovie:(ARNMovie *)arnMovie andCompletionBlock:(void (^)(NSString *))completion {
    __block NSString *sourceFile = [NSString string];
    
    if (arnMovie != nil && [arnMovie.archive_id length] > 0) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

        NSString *urlToFetch = [NSString stringWithFormat:@"%@%@%@", @"https://archive.org/metadata/", arnMovie.archive_id, @"/files"];
        [manager GET:urlToFetch parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            if (responseObject != nil && [responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *jsonDict = (NSDictionary *) responseObject;
                
                id filesId = [jsonDict objectForKey:@"result"];
                if (filesId != nil && [filesId isKindOfClass:[NSArray class]]) {
                    NSArray *files = (NSArray *)filesId;
                    
                    if (files != nil && [files count] > 0) {
                        
                        for (id fileId in files) {
                            if (fileId != nil && [fileId isKindOfClass:[NSDictionary class]]) {
                                
                                NSDictionary *file = (NSDictionary *)fileId;
                                
                                // parse out data we care about
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
                                                    sourceFile = name;
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if (completion != nil) {
                completion(sourceFile);
            }
        } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            if (completion != nil) {
                completion(sourceFile);
            }
        }];
    } else {
        if (completion != nil) {
            completion(sourceFile);
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
