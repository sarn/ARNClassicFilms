//
//  ARNArchiveController.h
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"
#import "ARNMovie.h"

@interface ARNArchiveController : NSObject

+ (ARNArchiveController *)sharedInstance;
- (void)fetchForCollection:(NSString *)collection withPageNumber:(NSInteger)page andRows:(NSInteger)rows;
- (void)fetchSourceFileForMovie:(ARNMovie *)arnMovie andCompletionBlock:(void (^)(NSString *))completion;

@end
