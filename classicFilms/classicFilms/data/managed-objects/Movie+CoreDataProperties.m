//
//  Movie+CoreDataProperties.m
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "Movie+CoreDataProperties.h"

@implementation Movie (CoreDataProperties)

@dynamic archive_id;
@dynamic tmdb_id;
@dynamic title;
@dynamic year;
@dynamic movie_description;
@dynamic posterURL;
@dynamic backdropURL;

@end
