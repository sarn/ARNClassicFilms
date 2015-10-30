//
//  ARNMovieDBController.h
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"

@interface ARNMovieDBController : NSObject

+ (ARNMovieDBController *)sharedInstance;
- (void)fetchMovieDetailsForMovies:(NSArray *)movies withManager:(AFHTTPSessionManager *)manager andCompletionBlock:(void (^)())completion;

@end
