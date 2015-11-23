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
#import "SDWebImagePrefetcher.h"

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
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate threadSafeManagedObjectContext];
        [context performBlockAndWait:^{
            // check if we already have the same object
            Movie *movie = nil;
            if (![arnMovie.archive_id isKindOfClass:[NSNull class]]) {
                NSFetchRequest *movieFetchRequest = [[NSFetchRequest alloc] init];
                movieFetchRequest.entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
                movieFetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                                                  [NSPredicate predicateWithFormat:@"tmdb_id == %@", arnMovie.tmdb_id],
                                                                                                  [NSPredicate predicateWithFormat:@"collection == %@", arnMovie.collection],
                                                                                                  nil]];
                
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
                movie.date_created = arnMovie.date_created;
            }
            
            // fill/update the data
            movie.archive_id = (![arnMovie.archive_id isKindOfClass:[NSNull class]] && [arnMovie.archive_id length] > 0) ? arnMovie.archive_id : [NSString string];
            movie.tmdb_id = (![arnMovie.tmdb_id isKindOfClass:[NSNull class]] && [arnMovie.tmdb_id length] > 0) ? arnMovie.tmdb_id : [NSString string];
            movie.title = (![arnMovie.title isKindOfClass:[NSNull class]] && [arnMovie.title length] > 0) ? arnMovie.title : [NSString string];
            movie.year = (![arnMovie.year isKindOfClass:[NSNull class]] && [arnMovie.year integerValue] >= 1800) ? arnMovie.year : @(0);
            movie.movie_description = (![arnMovie.movie_description isKindOfClass:[NSNull class]] && [arnMovie.movie_description length] > 0) ? arnMovie.movie_description : [NSString string];
            movie.posterURL = (![arnMovie.posterURL isKindOfClass:[NSNull class]] && [arnMovie.posterURL length] > 0) ? arnMovie.posterURL : [NSString string];
            // prefetch the image
            // this crashes a lot if we switch between the categories
            // maybe we can reenable this later with a newer version of SDWebImage
//            if ([movie.posterURL length] > 0) {
//                [[SDWebImagePrefetcher sharedImagePrefetcher] prefetchURLs:@[movie.posterURL]];
//            }
            
            movie.backdropURL = (![arnMovie.backdropURL isKindOfClass:[NSNull class]] && [arnMovie.backdropURL length] > 0) ? arnMovie.backdropURL : [NSString string];
            movie.source = (![arnMovie.source isKindOfClass:[NSNull class]] && [arnMovie.source length] > 0) ? arnMovie.source : [NSString string];
            movie.date_updated = arnMovie.date_updated;
            movie.license = arnMovie.license;
            
            // update collection information
            movie.collection = arnMovie.collection;
            movie.page_number = arnMovie.page_number;
            
            // save to Core Data
            [context save:nil];
        }];
    }
}

- (NSArray *)moviesForCollection:(NSString *)collection {
    NSMutableArray *movies = [NSMutableArray array];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate threadSafeManagedObjectContext];
    [context performBlockAndWait:^{
        NSFetchRequest *movieFetchRequest = [[NSFetchRequest alloc] init];
        movieFetchRequest.entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
        
        if ([collection length] > 0) {
            movieFetchRequest.predicate = [NSPredicate predicateWithFormat:@"collection == %@",collection];
        }
        
        // sort by year
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES];
        movieFetchRequest.sortDescriptors = @[descriptor];
        
        NSArray *results = [context executeFetchRequest:movieFetchRequest error:nil];
        for (id obj in results) {
            if (obj != nil && [obj isKindOfClass:[Movie class]]) {
                Movie *movie = (Movie *)obj;
                [movies addObject:[[ARNMovie alloc] initWithAttributesOfManagedObject:movie]];
            }
        }
    }];
    
    return movies;
}

@end
