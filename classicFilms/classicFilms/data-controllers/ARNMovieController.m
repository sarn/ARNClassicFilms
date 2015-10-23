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

- (NSArray *)moviesForCollection:(NSString *)collection {
    NSMutableArray *movies = [NSMutableArray array];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    
    NSFetchRequest *movieFetchRequest = [[NSFetchRequest alloc] init];
    movieFetchRequest.entity = [NSEntityDescription entityForName:@"Movie" inManagedObjectContext:context];
    
    if ([collection length] > 0) {
        movieFetchRequest.predicate = [NSPredicate predicateWithFormat:@"collection == %@",collection];
    }
    
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
