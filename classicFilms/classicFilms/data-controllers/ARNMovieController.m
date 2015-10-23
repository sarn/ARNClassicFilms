//
//  ARNMovieController.m
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieController.h"
#import "AppDelegate.h"
#import "ARNMovie.h"
#import "Movie.h"

@implementation ARNMovieController

+ (ARNMovieController *)sharedInstance {
    static ARNMovieController *instance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        instance = [[ARNMovieController alloc] init];
    });
    
    return instance;
}

- (void)addMovie:(ARNMovie *)arnMovie {
    if (arnMovie != nil) {
        // only save if we have enough data
        if ((![arnMovie.title isKindOfClass:[NSNull class]] && [arnMovie.title length] > 0) &&
            (![arnMovie.posterURL isKindOfClass:[NSNull class]] && [arnMovie.posterURL length] > 0)) {
            
            

            
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext *context = appDelegate.managedObjectContext;
            
            // save it to CoreData
            Movie *movie = nil;
            if (![arnMovie.archive_id isKindOfClass:[NSNull class]]) {
                NSFetchRequest *movieFetchRequest = [[NSFetchRequest alloc] init];
                movieFetchRequest.entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
                movieFetchRequest.predicate = [NSPredicate predicateWithFormat:@"tmdb_id == %@", arnMovie.tmdb_id];
                
                NSArray *result = [context executeFetchRequest:movieFetchRequest error:nil];
                if(result != nil && [result count] > 0){
                    id obj = [result lastObject];
                    if(obj != nil && [obj isKindOfClass:[Movie class]]){
                        movie = (Movie *) obj;
                    }
                }
            }
            
            
            
            // create new movie if there is not an existing one
            if(movie == nil){
                movie = (Movie *)[NSEntityDescription insertNewObjectForEntityForName:@"Movie" inManagedObjectContext:context];
            }
            
            // fill/update the data
            movie.archive_id = (![arnMovie.archive_id isKindOfClass:[NSNull class]] && [arnMovie.archive_id length] > 0) ? arnMovie.archive_id : [NSString string];
            movie.tmdb_id = (![arnMovie.tmdb_id isKindOfClass:[NSNull class]] && [arnMovie.tmdb_id length] > 0) ? arnMovie.tmdb_id : [NSString string];
            movie.title = (![arnMovie.title isKindOfClass:[NSNull class]] && [arnMovie.title length] > 0) ? arnMovie.title : [NSString string];
            movie.year = (![arnMovie.year isKindOfClass:[NSNull class]] && [arnMovie.year integerValue] >= 1800) ? arnMovie.year : @(0);
            movie.movie_description = (![arnMovie.movie_description isKindOfClass:[NSNull class]] && [arnMovie.movie_description length] > 0) ? arnMovie.movie_description : [NSString string];
            movie.posterURL = (![arnMovie.posterURL isKindOfClass:[NSNull class]] && [arnMovie.posterURL length] > 0) ? arnMovie.posterURL : [NSString string];
            movie.backdropURL = (![arnMovie.backdropURL isKindOfClass:[NSNull class]] && [arnMovie.backdropURL length] > 0) ? arnMovie.backdropURL : [NSString string];
            movie.source = (![arnMovie.source isKindOfClass:[NSNull class]] && [arnMovie.source length] > 0) ? arnMovie.source : [NSString string];
            
            // all collections have high prio except "feature film"
            // so only set feature film if we have an empty string and nothing else in the database
            if (![arnMovie.collection isKindOfClass:[NSNull class]] && [arnMovie.collection length] > 0) {
                if([arnMovie.collection caseInsensitiveCompare:COLLECTION_TYPE_FEATURE_FILM] == NSOrderedSame) {
                    if (![movie.collection length] > 0) {
                        movie.collection = arnMovie.collection;
                    }
                } else {
                    movie.collection = arnMovie.collection;
                }
            } else {
                movie.collection = [NSString string];
            }
            
            [context save:nil];
            
            // TODO: replace AFNetworking Image Cache with SDWebImage to preload all the posters and backdrops in te background to a Disc Cache (and not Ram Cache only like AFNetworking provides)
        }
    }
}

- (NSArray *)moviesForCollection:(NSString *)collection {
    NSMutableArray *movies = [NSMutableArray array];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest *movieFetchRequest = [[NSFetchRequest alloc] init];
    movieFetchRequest.entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
    
    if ([collection length] > 0) {
        movieFetchRequest.predicate = [NSPredicate predicateWithFormat:@"collection == %@",collection];
    }
    
    // sort by year
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"year" ascending:NO];
    movieFetchRequest.sortDescriptors = @[descriptor];
    
    NSArray *results = [context executeFetchRequest:movieFetchRequest error:nil];
    for (id obj in results) {
        if (obj != nil && [obj isKindOfClass:[Movie class]]) {
            Movie *movie = (Movie *)obj;
            [movies addObject:[[ARNMovie alloc] initWithAttributesOfManagedObject:movie]];
        }
    }
    
    return movies;
}

@end
