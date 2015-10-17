//
//  Movie+CoreDataProperties.h
//  classicFilms
//
//  Created by Stefan Arn on 17/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie.h"

NS_ASSUME_NONNULL_BEGIN

@interface Movie (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *archive_id;
@property (nullable, nonatomic, retain) NSString *backdropURL;
@property (nullable, nonatomic, retain) NSString *movie_description;
@property (nullable, nonatomic, retain) NSString *posterURL;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) NSString *tmdb_id;
@property (nullable, nonatomic, retain) NSNumber *year;
@property (nullable, nonatomic, retain) NSString *source;

@end

NS_ASSUME_NONNULL_END
