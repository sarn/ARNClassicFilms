//
//  ARNMovieController.h
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARNMovie.h"

@interface ARNMovieController : NSObject

+ (ARNMovieController *)sharedInstance;
- (void)addMovie:(ARNMovie *)arnMovie;
- (NSArray *)moviesForCollection:(NSString *)collection;

@end
