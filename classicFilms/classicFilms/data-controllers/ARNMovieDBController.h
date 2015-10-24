//
//  ARNMovieDBController.h
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "ARNMovie.h"

@interface ARNMovieDBController : NSObject

+ (ARNMovieDBController *)sharedInstance;
- (void)fetchMovieDetailsForMovie:(ARNMovie *)arnMovie withManager:(AFHTTPSessionManager *)manager andDispatchGroup:(dispatch_group_t)fetchMovieDataGroup;

@end
