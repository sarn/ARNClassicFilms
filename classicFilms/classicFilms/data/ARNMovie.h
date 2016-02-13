//
//  ARNMovie.h
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ARNDataObject.h"

@interface ARNMovie : ARNDataObject <NSCopying>

@property (nonatomic, copy) NSString * archive_id;
@property (nonatomic, copy) NSString * tmdb_id;
@property (nonatomic, copy) NSString * title;
@property (nonatomic, strong) NSNumber * year;
@property (nonatomic, strong) NSNumber * decade;
@property (nonatomic, copy) NSString * movie_description;
@property (nonatomic, copy) NSString * posterURL;
@property (nonatomic, copy) NSString * backdropURL;
@property (nonatomic, copy) NSString * source;
@property (nonatomic, copy) NSString * collection;
@property (nonatomic, strong) NSDate * date_created;
@property (nonatomic, strong) NSDate * date_updated;
@property (nonatomic, strong) NSNumber * page_number;
@property (nonatomic, copy) NSString * license;
@property (nonatomic, copy) NSString *original_title;
@property (nonatomic, strong) NSDecimalNumber *tmdb_rating;
@property (nonatomic, strong) NSDecimalNumber *imdb_rating;
@property (nonatomic, strong) NSNumber * runtime;

- (id)copyWithZone:(NSZone *)zone;

@end
