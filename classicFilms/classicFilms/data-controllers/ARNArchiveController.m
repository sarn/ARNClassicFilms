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
            
            NSLog(@"title: %@", [movie objectForKey:@"title"]);
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
        
        [[ARNMovieDBController sharedInstance] fetchMovieDetailsForCollection:movies];
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];

    // TODO: attribute archive.org and themoviedb.org
    
    // TODO: limit the return values from archive.org to only the stuff we need

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
