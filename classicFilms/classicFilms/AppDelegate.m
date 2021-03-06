//
//  AppDelegate.m
//  classicFilms
//
//  Created by Stefan Arn on 11/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "AppDelegate.h"
#import "ARNMovieOverviewController.h"
#import "ARNAboutViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // fabric.io
    [Fabric with:@[[Crashlytics class]]];

//    ARNMovieOverviewController *featureFilmController = [ARNMovieOverviewController new];
//    featureFilmController.collectionType = [NSString stringWithFormat:@"%@ NOT %@ NOT %@ NOT %@", COLLECTION_TYPE_FEATURE_FILM, COLLECTION_TYPE_SCIFI_HORROR, COLLECTION_TYPE_COMEDY, COLLECTION_TYPE_SILENT];
//    featureFilmController.title = NSLocalizedString(COLLECTION_TYPE_FEATURE_FILM, nil);
    
    ARNMovieOverviewController *filmNoirController = [ARNMovieOverviewController new];
    filmNoirController.collectionType = COLLECTION_TYPE_FILM_NOIR;
    //filmNoirController.collectionTypeExclusion = [NSString stringWithFormat:@"NOT %@ NOT %@ NOT %@", COLLECTION_TYPE_SCIFI_HORROR, COLLECTION_TYPE_COMEDY, COLLECTION_TYPE_SILENT];
    filmNoirController.title = NSLocalizedString(COLLECTION_TYPE_FILM_NOIR, nil);
    
    ARNMovieOverviewController *sciFiHorrorController = [ARNMovieOverviewController new];
    sciFiHorrorController.collectionType = COLLECTION_TYPE_SCIFI_HORROR;
    //sciFiHorrorController.collectionTypeExclusion = [NSString stringWithFormat:@"NOT %@ NOT %@", COLLECTION_TYPE_COMEDY, COLLECTION_TYPE_SILENT];
    sciFiHorrorController.title = NSLocalizedString(COLLECTION_TYPE_SCIFI_HORROR, nil);
    
    ARNMovieOverviewController *comedyFilmsController = [ARNMovieOverviewController new];
    comedyFilmsController.collectionType = COLLECTION_TYPE_COMEDY;
    comedyFilmsController.title = NSLocalizedString(COLLECTION_TYPE_COMEDY, nil);
    
    ARNMovieOverviewController *silentFilmsController = [ARNMovieOverviewController new];
    silentFilmsController.collectionType = COLLECTION_TYPE_SILENT;
    silentFilmsController.title = NSLocalizedString(COLLECTION_TYPE_SILENT, nil);
    
    ARNAboutViewController *aboutController = [ARNAboutViewController new];
    aboutController.title = NSLocalizedString(@"About", nil);
    
    UITabBarController *tabBarController = [UITabBarController new];
    tabBarController.viewControllers = [NSArray arrayWithObjects:filmNoirController, sciFiHorrorController, comedyFilmsController, silentFilmsController, aboutController, nil];
    
    self.window.rootViewController = tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationCachesDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "ch.stefanarn.ClassicFilms" in the application's caches directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"ClassicFilms" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationCachesDirectory] URLByAppendingPathComponent:@"ClassicFilms.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    NSDictionary *options = @{NSMigratePersistentStoresAutomaticallyOption : @YES,NSInferMappingModelAutomaticallyOption : @YES};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

// This method returns the correct managedObjectContect for the caller
// If the caller is the main thread (UI thread) it's allowed to use the
// managedObjectContext, which this method returns. If the caller
// is a background thread a new NSPrivateQueueConcurrencyType is created and returned.
-(NSManagedObjectContext *)threadSafeManagedObjectContext {
    if ([NSThread isMainThread]) {
        return [self managedObjectContext];
    } else {
        NSManagedObjectContext *managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [managedObjectContext performBlockAndWait:^{
            managedObjectContext.parentContext = [self managedObjectContext];
            managedObjectContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy;
        }];
        return managedObjectContext;
    }
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = [self threadSafeManagedObjectContext];
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end