//
//  ARNArchiveController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNArchiveController.h"
#import "AFHTTPSessionManager.h"

@implementation ARNArchiveController

+ (ARNArchiveController *)sharedInstance {
    static ARNArchiveController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNArchiveController alloc] init];
    });
    
    return instance;
}

- (NSArray *)fetchMovieArchiveForCollection:(NSString *)collection {
    __block NSArray *movies = [NSArray array];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSDictionary *parameters = @{@"q": @"mediatype:(movies) AND collection:(feature_films)",
                                 @"sort": @[@"downloads desc"],
                                 @"rows": @50,
                                 @"page": @1,
                                 @"output": @"json"};
    
    [manager GET:@"https://archive.org/advancedsearch.php" parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
        NSDictionary *jsonDict = (NSDictionary *) responseObject;
        
        NSDictionary *responseDict = (NSDictionary *)[jsonDict objectForKey:@"response"];
        NSArray *moviesArray = (NSArray *)[responseDict objectForKey:@"docs"];
        
        for (NSDictionary *movie in moviesArray) {
            // parse out data we care about
            
            NSLog(@"title: %@", [movie objectForKey:@"title"]);
            NSLog(@"identifier: %@", [movie objectForKey:@"identifier"]);
            NSLog(@"description: %@", [movie objectForKey:@"description"]);
            NSLog(@"date: %@", [movie objectForKey:@"date"]);
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
            NSDate *date = [dateFormatter dateFromString:[movie objectForKey:@"date"]];
            NSLog(@"year: %ld", (long)[self getYear:date]);
            
            
            NSLog(@"*****************************");
        }
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        NSLog(@"Error: %@", error);
    }];

    // TODO: attribute archive.org and themoviedb.org
    
    return movies;
}

- (NSInteger)getYear:(NSDate*)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear fromDate:date];
    return [components year];
}

@end
