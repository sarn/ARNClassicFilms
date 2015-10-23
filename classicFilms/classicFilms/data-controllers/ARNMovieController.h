//
//  ARNMovieController.h
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNMovieController : NSObject

+ (ARNMovieController *)sharedInstance;
- (NSArray *)moviesForCollection:(NSString *)collection;

@end
