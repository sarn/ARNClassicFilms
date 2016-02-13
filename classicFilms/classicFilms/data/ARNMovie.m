//
//  ARNMovie.m
//  classicFilms
//
//  Created by Stefan Arn on 12/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovie.h"

@implementation ARNMovie

- (id)copyWithZone:(NSZone *)zone {
    ARNMovie *arnMovie = [[ARNMovie allocWithZone:zone] init];
    arnMovie.archive_id = [self.archive_id copyWithZone:zone];
    arnMovie.tmdb_id = [self.tmdb_id copyWithZone:zone];
    arnMovie.title = [self.title copyWithZone:zone];
    arnMovie.year = [self.year copyWithZone:zone];
    arnMovie.decade = [self.decade copyWithZone:zone];
    arnMovie.movie_description = [self.movie_description copyWithZone:zone];
    arnMovie.posterURL = [self.posterURL copyWithZone:zone];
    arnMovie.backdropURL = [self.backdropURL copyWithZone:zone];
    arnMovie.source = [self.source copyWithZone:zone];
    arnMovie.collection = [self.collection copyWithZone:zone];
    arnMovie.date_created = [self.date_created copyWithZone:zone];
    arnMovie.date_updated = [self.date_updated copyWithZone:zone];
    arnMovie.page_number = [self.page_number copyWithZone:zone];
    arnMovie.license = [self.license copyWithZone:zone];
    arnMovie.original_title = [self.original_title copyWithZone:zone];
    arnMovie.tmdb_rating = [self.tmdb_rating copyWithZone:zone];
    arnMovie.imdb_rating = [self.imdb_rating copyWithZone:zone];
    arnMovie.runtime = [self.runtime copyWithZone:zone];
    
    return arnMovie;
}

@end
