//
//  ARNCloudKitController.h
//  classicFilms
//
//  Created by Stefan Arn on 23/11/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ARNCloudKitController : NSObject

+ (ARNCloudKitController *)sharedInstance;
- (void)fetchAllMoviesForCollection:(NSString *)collection;

@end
