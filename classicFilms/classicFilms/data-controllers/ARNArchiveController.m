//
//  ARNArchiveController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNArchiveController.h"
#import "ARNMovieController.h"

@implementation ARNArchiveController

+ (ARNArchiveController *)sharedInstance {
    static ARNArchiveController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNArchiveController alloc] init];
    });
    
    return instance;
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

@end
