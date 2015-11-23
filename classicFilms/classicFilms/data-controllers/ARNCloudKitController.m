//
//  ARNCloudKitController.m
//  classicFilms
//
//  Created by Stefan Arn on 23/11/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNCloudKitController.h"
#import <CloudKit/CloudKit.h>
#import "ARNMovieController.h"
#import "ARNMovie.h"

@implementation ARNCloudKitController

+ (ARNCloudKitController *)sharedInstance {
    static ARNCloudKitController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNCloudKitController alloc] init];
    });
    
    return instance;
}

- (void)fetchAllMoviesForCollection:(NSString *)collection {
    if ([collection length] > 0) {
        CKDatabase *publicDatabase = [[CKContainer defaultContainer] publicCloudDatabase];
        
        NSPredicate *collectionPredicate = [NSPredicate predicateWithFormat:@"collection == %@", collection];
        
        CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Movies" predicate:collectionPredicate];
        query.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES]];
        
        [self fetchAllMoviesFromDatabase:publicDatabase withQuery:query andCursor:nil];
    }
}

- (void)fetchAllMoviesFromDatabase:(CKDatabase *)database withQuery:(CKQuery *)query andCursor:(CKQueryCursor *)cursor {
    if (database != nil && (query != nil || cursor != nil)) {
        CKQueryOperation *operation = nil;
        if (query != nil) {
            operation = [[CKQueryOperation alloc] initWithQuery:query];
        } else {
            operation = [[CKQueryOperation alloc] initWithCursor:cursor];
        }
        
        if (operation != nil) {
            // set the fetch limit
            operation.resultsLimit = CKQueryOperationMaximumResults;
            //operation.resultsLimit = 10;
            
            // handle a single record
            operation.recordFetchedBlock = ^(CKRecord *movieRecord) {
                if (movieRecord != nil) {
                    // create arnMovie object for local storage
                    ARNMovie *arnMovie = [[ARNMovie alloc] init];
                    arnMovie.archive_id = ([movieRecord objectForKey:@"archive_id"] != nil && [[movieRecord objectForKey:@"archive_id"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"archive_id"] : [NSString string];
                    arnMovie.tmdb_id = ([movieRecord objectForKey:@"tmdb_id"] != nil && [[movieRecord objectForKey:@"tmdb_id"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"tmdb_id"] : [NSString string];
                    arnMovie.title = ([movieRecord objectForKey:@"title"] != nil && [[movieRecord objectForKey:@"title"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"title"] : [NSString string];
                    arnMovie.year = ([movieRecord objectForKey:@"year"] != nil && [[movieRecord objectForKey:@"year"] longValue] >= 1800) ? @([[movieRecord objectForKey:@"year"] longValue]) : @(0);
                    arnMovie.movie_description = ([movieRecord objectForKey:@"movie_description"] != nil && [[movieRecord objectForKey:@"movie_description"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"movie_description"] : [NSString string];
                    arnMovie.posterURL = ([movieRecord objectForKey:@"posterURL"] != nil && [[movieRecord objectForKey:@"posterURL"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"posterURL"] : [NSString string];
                    arnMovie.backdropURL = ([movieRecord objectForKey:@"backdropURL"] != nil && [[movieRecord objectForKey:@"backdropURL"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"backdropURL"] : [NSString string];
                    arnMovie.source = ([movieRecord objectForKey:@"source"] != nil && [[movieRecord objectForKey:@"source"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"source"] : [NSString string];
                    arnMovie.collection = ([movieRecord objectForKey:@"collection"] != nil && [[movieRecord objectForKey:@"collection"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"collection"] : [NSString string];
                    arnMovie.date_created = ([movieRecord objectForKey:@"date_created"] != nil && [[movieRecord objectForKey:@"date_created"] isKindOfClass:[NSDate class]]) ? [movieRecord objectForKey:@"date_created"] : [NSDate dateWithTimeIntervalSince1970:0.0];
                    arnMovie.date_updated = ([movieRecord objectForKey:@"date_updated"] != nil && [[movieRecord objectForKey:@"date_updated"] isKindOfClass:[NSDate class]]) ? [movieRecord objectForKey:@"date_updated"] : [NSDate dateWithTimeIntervalSince1970:0.0];
                    arnMovie.page_number = ([movieRecord objectForKey:@"page_number"] != nil && [[movieRecord objectForKey:@"page_number"] longValue] >= 0) ? @([[movieRecord objectForKey:@"page_number"] longValue]) : @(-1);
                    arnMovie.license = ([movieRecord objectForKey:@"license"] != nil && [[movieRecord objectForKey:@"license"] isKindOfClass:[NSString class]]) ? [movieRecord objectForKey:@"license"] : [NSString string];
                    
                    // save it
                    [[ARNMovieController sharedInstance] addMovie:arnMovie];
                }
            };
            
            // handle a query completion
            operation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *error) {
                if (!error) {
                    // success
                    if (cursor != nil) {
                        // start the next batch operation
                        [self fetchAllMoviesFromDatabase:database withQuery:nil andCursor:cursor];
                    }
                } else {
                    // failure
                    NSLog(@"fetchAllMoviesFromDatabase failed with error: %@", error.localizedDescription);
                }
            };
            
            // start the operation
            [database addOperation:operation];
        }
    }
}

@end
