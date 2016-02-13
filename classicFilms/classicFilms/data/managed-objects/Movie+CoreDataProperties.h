//
//  Movie+CoreDataProperties.h
//  classicFilms
//
//  Created by Stefan Arn on 12/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface Movie (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *archive_id;
@property (nullable, nonatomic, retain) NSString *backdropURL;
@property (nullable, nonatomic, retain) NSString *collection;
@property (nullable, nonatomic, retain) NSDate *date_created;
@property (nullable, nonatomic, retain) NSDate *date_updated;
@property (nullable, nonatomic, retain) NSNumber *decade;
@property (nullable, nonatomic, retain) NSString *license;
@property (nullable, nonatomic, retain) NSString *movie_description;
@property (nullable, nonatomic, retain) NSNumber *page_number;
@property (nullable, nonatomic, retain) NSString *posterURL;
@property (nullable, nonatomic, retain) NSString *source;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *tmdb_id;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSString *original_title;
@property (nullable, nonatomic, retain) NSDecimalNumber *tmdb_rating;
@property (nullable, nonatomic, retain) NSDecimalNumber *imdb_rating;
@property (nullable, nonatomic, retain) NSNumber *runtime;

@end

NS_ASSUME_NONNULL_END
