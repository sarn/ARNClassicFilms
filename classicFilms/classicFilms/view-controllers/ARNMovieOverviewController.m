//
//  ARNMovieOverviewController.m
//  classicFilms
//
//  Created by Stefan Arn on 11/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieOverviewController.h"
#import "ARNCollectionViewFocusGuideFlowLayout.h"
#import "ARNMovieDetailViewController.h"
#import "ARNCloudKitController.h"
#import "ARNMovieController.h"
#import "ARNMoviePosterCell.h"
#import "ARNDecadeHeaderView.h"
#import "ARNFocusGuideSupplementaryView.h"
#import "ARNMovie.h"
#import "Movie.h"
#import "AppDelegate.h"
#import "ARNAppearanceViewController.h"

@interface ARNMovieOverviewController ()
    @property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
    @property(nonatomic, strong) UICollectionView *collectionView;
    @property(nonatomic, strong) UIActivityIndicatorView *refreshActivityIndicator;
    @property(nonatomic, strong) NSMutableDictionary *objectChanges;
    @property(nonatomic, strong) NSMutableDictionary *sectionChanges;
    @property(nonatomic, assign) BOOL shouldRefreshOnAppearing;
@end

@implementation ARNMovieOverviewController

- (id)init
{
    self = [super init];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if(self)
    {
        [self setup];
    }
    return self;
}

// common setup method used by both init's
- (void)setup
{
    _collectionType = [NSString string];
    _collectionTypeExclusion = [NSString string];
    _objectChanges = [NSMutableDictionary new];
    _sectionChanges = [NSMutableDictionary new];
    _shouldRefreshOnAppearing = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // layout
    
    // We need to use a custom FlowLayout to get rid of a known bug in the standard UICollectionViewFlowLayout (radar bug #26803196 & #22392869)
    //
    // Apple Engineering replied the following:
    // "The 'moves down even if nothing is directly beneath it' rule only works within the last section of the collection view.
    // It doesn’t work in this app because the final rows are in different sections. This is a known issue for which we are
    // investigating a fix in a future release. Yu can work around the issue by using focus guides or refactoring the layout of your collection view."
    //
    // To prevent this issue we use a custom FlowLayout that helps the layout by placing FocusGuides into the empty spots. This directs
    // the Focus to the correct target. We can switch back to the standard UICollectionViewFLowLayout if Apple fixes the bug in a future release.
    ARNCollectionViewFocusGuideFlowLayout *focusGuideFlowLayout = [[ARNCollectionViewFocusGuideFlowLayout alloc] init];
    //UICollectionViewFlowLayout *focusGuideFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    [focusGuideFlowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [focusGuideFlowLayout setMinimumLineSpacing:30.0f];
    [focusGuideFlowLayout setMinimumInteritemSpacing:20.0f];
    [focusGuideFlowLayout setSectionInset:UIEdgeInsetsMake(0.0f, 80.0f, 0.0f, 80.0f)];
    [focusGuideFlowLayout setItemSize:CGSizeMake(256, 464)];
    [focusGuideFlowLayout setHeaderReferenceSize:CGSizeMake(self.view.frame.size.width, 150.0f)];
    
    // collection view
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:focusGuideFlowLayout];
    self.collectionView.contentInset = UIEdgeInsetsMake(140.0f, 0.0f, 80.0f, 0.0f);
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.remembersLastFocusedIndexPath = YES;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // register collection view elements
    [self.collectionView registerClass:[ARNMoviePosterCell class] forCellWithReuseIdentifier:@"ARNMoviePosterCell"];
    [self.collectionView registerClass:[ARNDecadeHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ARNDecadeHeaderView"];
    [self.collectionView registerClass:[ARNFocusGuideSupplementaryView class] forSupplementaryViewOfKind:ARNCollectionElementKindFocusGuide withReuseIdentifier:@"ARNFocusGuideSupplementaryView"];
    
    // add everything to view hirarchy
    [self.view addSubview:self.collectionView];
    
    // activity indicator
    self.refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.refreshActivityIndicator.frame = self.view.frame;
    self.refreshActivityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.refreshActivityIndicator];
    [self.refreshActivityIndicator startAnimating];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // refresh the movies if the user jumps to this viewController
    // for the first time, thru the tab bar and not
    // if he moves back from a detail view
    if (self.shouldRefreshOnAppearing) {
        // set up the fetcher for the data
        [[self fetchedResultsController] performFetch:nil];
        
        // fetch the movies
        [[ARNCloudKitController sharedInstance] fetchAllMoviesForCollection:self.collectionType];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.shouldRefreshOnAppearing = YES; // reset to the default behaviour
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    
    // only fetch valid objects for our collection
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                                 [NSPredicate predicateWithFormat:@"collection == %@", self.collectionType],
                                                                                 [NSPredicate predicateWithFormat:@"tmdb_id != nil AND tmdb_id != ''"],
                                                                                 [NSPredicate predicateWithFormat:@"title != nil AND title != ''"],
                                                                                 [NSPredicate predicateWithFormat:@"posterURL != nil AND posterURL != ''"],
                                                                                 [NSPredicate predicateWithFormat:@"source != nil AND source != ''"],
                                                                                 nil]];

    // sort by year
    NSSortDescriptor *yearDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES];
    NSSortDescriptor *tmdbIdDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tmdb_id" ascending:YES];
    fetchRequest.sortDescriptors = @[yearDescriptor, tmdbIdDescriptor];
    
    // fetcher
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:@"decade"
                                                                                                          cacheName:nil];
    
    self.fetchedResultsController = fetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    return _fetchedResultsController;
}


#pragma mark -
#pragma mark UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[_fetchedResultsController sections] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    NSUInteger numberOfItems = [sectionInfo numberOfObjects];
    if (numberOfItems > 0) {
        [self.refreshActivityIndicator stopAnimating];
    } else {
        [self.refreshActivityIndicator startAnimating];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // setup cell identifier
    ARNMoviePosterCell *cell = (ARNMoviePosterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ARNMoviePosterCell" forIndexPath:indexPath];
    
    id obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (obj != nil) {
        if ([obj isKindOfClass:[Movie class]]) {
            [cell configureCellWithMovie:[[ARNMovie alloc] initWithAttributesOfManagedObject:obj]];
        }
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        // setup header view identifier
        ARNDecadeHeaderView *movieOverviewHeaderView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"ARNDecadeHeaderView" forIndexPath:indexPath];
        
        // set the title
        id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections] [indexPath.section];
        id obj = sectionInfo.objects.firstObject;
        if (obj != nil && [obj isKindOfClass:[Movie class]]) {
            Movie *movie = (Movie *)obj;
            NSString *decade = [movie.decade stringValue];
            [movieOverviewHeaderView configureViewWithTitle:[NSString stringWithFormat:@"%@s", decade]];
        }
        
        return movieOverviewHeaderView;
    } else if (kind == ARNCollectionElementKindFocusGuide) {
        ARNFocusGuideSupplementaryView *focusGuideSupplementaryView = [collectionView dequeueReusableSupplementaryViewOfKind:ARNCollectionElementKindFocusGuide withReuseIdentifier:@"ARNFocusGuideSupplementaryView" forIndexPath:indexPath];
        
        // set the prefered focus view
        // get the last cell of the section
        NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:indexPath.section];
        NSIndexPath *indexPathOfLastCellOfSection = [NSIndexPath indexPathForItem:(numberOfItems - 1) inSection:indexPath.section];
        UICollectionViewCell *lastCellOfSection = [self.collectionView cellForItemAtIndexPath:indexPathOfLastCellOfSection];

        // point the focus view to the last cell of the section
        [focusGuideSupplementaryView configureViewWithPreferredFocusedView:lastCellOfSection];
        
        return focusGuideSupplementaryView;
    } else {
        return nil;
    }
}


#pragma mark -
#pragma mark UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell != nil && [cell isKindOfClass:[ARNMoviePosterCell class]]) {
        ARNMoviePosterCell *posterCell = (ARNMoviePosterCell *)cell;
        if (posterCell.arnMovie != nil) {
            self.shouldRefreshOnAppearing = NO; // to prevent a refresh if we pop this child view away
            
            // present child view
            ARNMovieDetailViewController *movieDetailViewController = [ARNMovieDetailViewController new];
            movieDetailViewController.arnMovie = posterCell.arnMovie;
            
            // use ARNAppearanceViewController to force the UIUserInterfaceStyleDark on the ARNMovieDetailViewController
            ARNAppearanceViewController *appearanceViewController = [ARNAppearanceViewController new];
            appearanceViewController.interfaceStyle = UIUserInterfaceStyleDark;
            [appearanceViewController setViewController:movieDetailViewController];
            
            [self presentViewController:appearanceViewController animated:YES completion:nil];
        }
    }
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

// implementation is based on AFMasterViewController:
// https://github.com/ashfurrow/UICollectionView-NSFetchedResultsController/blob/459cd1c3b167fc8d368845e9ff7bbd40b8070630/AFMasterViewController.m
// the simpler looking code from blake water unfortunately crashed under heavy load (first start with multiple ongoing fetches)
// https://github.com/AshFurrow/UICollectionView-NSFetchedResultsController/issues/13
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.objectChanges = [NSMutableDictionary dictionary];
    self.sectionChanges = [NSMutableDictionary dictionary];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    if (type == NSFetchedResultsChangeInsert || type == NSFetchedResultsChangeDelete) {
        NSMutableIndexSet *changeSet = self.sectionChanges[@(type)];
        if (changeSet != nil) {
            [changeSet addIndex:sectionIndex];
        } else {
            self.sectionChanges[@(type)] = [[NSMutableIndexSet alloc] initWithIndex:sectionIndex];
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableArray *changeSet = self.objectChanges[@(type)];
    if (changeSet == nil) {
        changeSet = [[NSMutableArray alloc] init];
        self.objectChanges[@(type)] = changeSet;
    }
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [changeSet addObject:newIndexPath];
            break;
        case NSFetchedResultsChangeDelete:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeUpdate:
            [changeSet addObject:indexPath];
            break;
        case NSFetchedResultsChangeMove:
            [changeSet addObject:@[indexPath, newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    NSMutableArray *moves = self.objectChanges[@(NSFetchedResultsChangeMove)];
    if (moves.count > 0) {
        NSMutableArray *updatedMoves = [[NSMutableArray alloc] initWithCapacity:moves.count];
        
        NSMutableIndexSet *insertSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        NSMutableIndexSet *deleteSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        for (NSArray *move in moves) {
            NSIndexPath *fromIP = move[0];
            NSIndexPath *toIP = move[1];
            
            if ([deleteSections containsIndex:fromIP.section]) {
                if (![insertSections containsIndex:toIP.section]) {
                    NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeInsert)];
                    if (changeSet == nil) {
                        changeSet = [[NSMutableArray alloc] initWithObjects:toIP, nil];
                        self.objectChanges[@(NSFetchedResultsChangeInsert)] = changeSet;
                    } else {
                        [changeSet addObject:toIP];
                    }
                }
            } else if ([insertSections containsIndex:toIP.section]) {
                NSMutableArray *changeSet = self.objectChanges[@(NSFetchedResultsChangeDelete)];
                if (changeSet == nil) {
                    changeSet = [[NSMutableArray alloc] initWithObjects:fromIP, nil];
                    self.objectChanges[@(NSFetchedResultsChangeDelete)] = changeSet;
                } else {
                    [changeSet addObject:fromIP];
                }
            } else {
                [updatedMoves addObject:move];
            }
        }
        
        if (updatedMoves.count > 0) {
            self.objectChanges[@(NSFetchedResultsChangeMove)] = updatedMoves;
        } else {
            [self.objectChanges removeObjectForKey:@(NSFetchedResultsChangeMove)];
        }
    }
    
    NSMutableArray *deletes = self.objectChanges[@(NSFetchedResultsChangeDelete)];
    if (deletes.count > 0) {
        NSMutableIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        [deletes filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![deletedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    NSMutableArray *inserts = self.objectChanges[@(NSFetchedResultsChangeInsert)];
    if (inserts.count > 0) {
        NSMutableIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        [inserts filterUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath *evaluatedObject, NSDictionary *bindings) {
            return ![insertedSections containsIndex:evaluatedObject.section];
        }]];
    }
    
    UICollectionView *collectionView = self.collectionView;
    
    [collectionView performBatchUpdates:^{
        NSIndexSet *deletedSections = self.sectionChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedSections.count > 0) {
            [collectionView deleteSections:deletedSections];
        }
        
        NSIndexSet *insertedSections = self.sectionChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedSections.count > 0) {
            [collectionView insertSections:insertedSections];
        }
        
        NSArray *deletedItems = self.objectChanges[@(NSFetchedResultsChangeDelete)];
        if (deletedItems.count > 0) {
            [collectionView deleteItemsAtIndexPaths:deletedItems];
        }
        
        NSArray *insertedItems = self.objectChanges[@(NSFetchedResultsChangeInsert)];
        if (insertedItems.count > 0) {
            [collectionView insertItemsAtIndexPaths:insertedItems];
        }
        
        NSArray *reloadItems = self.objectChanges[@(NSFetchedResultsChangeUpdate)];
        if (reloadItems.count > 0) {
            [collectionView reloadItemsAtIndexPaths:reloadItems];
        }
        
        NSArray *moveItems = self.objectChanges[@(NSFetchedResultsChangeMove)];
        for (NSArray *paths in moveItems) {
            [collectionView moveItemAtIndexPath:paths[0] toIndexPath:paths[1]];
        }
        
        // to remove the supplementary views completely,
        // we have to do a reload of the data here
        //
        // this is only needed if we use the
        // ARNCollectionViewFocusGuideFlowLayout
        //
        // [collectionView reloadData] would lead to a crash
        // as decribed here: http://stackoverflow.com/a/38017481/956433
        //
        // But we can use invalidateLayout instead without
        // a crash to achieve the same thing
        //
        // Thanks to the helpful Apple Engineer at WWDC that
        // showed me this solution :-) Much appreciated
        [[collectionView collectionViewLayout] invalidateLayout];
    } completion:nil];
    
    self.objectChanges = nil;
    self.sectionChanges = nil;
}

- (void)dealloc {
    _fetchedResultsController.delegate = nil;
}

@end
