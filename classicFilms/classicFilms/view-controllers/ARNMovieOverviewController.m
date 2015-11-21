//
//  FirstViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 11/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieOverviewController.h"
#import "ARNArchiveController.h"
#import "ARNMovieController.h"
#import "ARNMoviePosterCell.h"
#import "ARNMovie.h"
#import "Movie.h"
#import "AppDelegate.h"
#import <AVKit/AVKit.h>

@interface ARNMovieOverviewController ()
    @property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
    @property(nonatomic, strong) UICollectionView *collectionView;
    @property(nonatomic, strong) UIActivityIndicatorView *refreshActivityIndicator;
    @property(nonatomic, strong) NSMutableDictionary *objectChanges;
    @property(nonatomic, strong) NSMutableDictionary *sectionChanges;
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

// common setup method used be init's
- (void)setup
{
    _collectionType = [NSString string];
    _collectionTypeExlusion = [NSString string];
    _objectChanges = [NSMutableDictionary new];
    _sectionChanges = [NSMutableDictionary new];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // layout
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setMinimumLineSpacing:0.0f];
    [flowLayout setMinimumInteritemSpacing:0.0f];
    
    // collection view
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:flowLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    // register custom cells
    [self.collectionView registerClass:[ARNMoviePosterCell class] forCellWithReuseIdentifier:@"ARNMoviePosterCell"];
    
    // add eveything to view hirarchy
    [self.view addSubview:self.collectionView];
    
    // activity indicator
    self.refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.refreshActivityIndicator.frame = self.view.frame;
    self.refreshActivityIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.refreshActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // set up the fetcher for the data
    [[self fetchedResultsController] performFetch:nil];
    
    // fetch the first few movies
    [[ARNArchiveController sharedInstance] fetchForCollection:self.collectionType withExclusion:self.collectionTypeExlusion andPageNumber:1 withRows:ARCHIVE_ORG_ROW_COUNT];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if(_fetchedResultsController != nil)
    {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Movie"];
    
    // only fetch valid object for our collection
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:
                                                                                 [NSPredicate predicateWithFormat:@"collection == %@", self.collectionType],
                                                                                 [NSPredicate predicateWithFormat:@"tmdb_id != nil AND tmdb_id != ''"],
                                                                                 [NSPredicate predicateWithFormat:@"title != nil AND title != ''"],
                                                                                 [NSPredicate predicateWithFormat:@"posterURL != nil AND posterURL != ''"],
                                                                                 nil]];

    // sort by year
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"year" ascending:YES];
    fetchRequest.sortDescriptors = @[descriptor];
    
    // fetcher
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext;
    NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                               managedObjectContext:context
                                                                                                 sectionNameKeyPath:nil
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
    // Setup cell identifier
    ARNMoviePosterCell *cell = (ARNMoviePosterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ARNMoviePosterCell" forIndexPath:indexPath];
    
    id obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (obj != nil) {
        if ([obj isKindOfClass:[Movie class]]) {
            [cell configureCellWithMovie:[[ARNMovie alloc] initWithAttributesOfManagedObject:obj]];
        }
    }
    
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    if (cell != nil && [cell isKindOfClass:[ARNMoviePosterCell class]]) {
        ARNMoviePosterCell *posterCell = (ARNMoviePosterCell *)cell;
        if (posterCell.arnMovie != nil) {
            [posterCell showActivityIndicator];
            [[ARNArchiveController sharedInstance] fetchSourceFileForMovie:posterCell.arnMovie andCompletionBlock:^(NSString *sourceFile) {
                [posterCell stopActivityIndicator];
                if ([sourceFile length] > 0) {
                    // open the stream
                    // https://archive.org/download/night_of_the_living_dead/night_of_the_living_dead_512kb.mp4
                    NSString *videoStream = [NSString stringWithFormat:@"%@%@/%@", @"https://archive.org/download/", posterCell.arnMovie.archive_id, sourceFile];
                    
                    NSURL *videoURL = [NSURL URLWithString:videoStream];
                    AVPlayer *player = [AVPlayer playerWithURL:videoURL];
                    
                    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                    playerViewController.player = player;
                    
                    [self presentViewController:playerViewController animated:YES completion:^{
                        [player play];
                    }];
                }
            }];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUpdateFocusInContext:(UICollectionViewFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    // the focus got changed, let's check which cell got focused and if we need to load more cells from the backend
    NSInteger focusedCellNumber = context.nextFocusedIndexPath.row + 1;
    NSInteger totalCellNumber = [collectionView numberOfItemsInSection:context.nextFocusedIndexPath.section];
    NSInteger distanceToLastCell = totalCellNumber - focusedCellNumber;
    
    if(distanceToLastCell < 24) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:context.nextFocusedIndexPath];
        if (cell != nil && [cell isKindOfClass:[ARNMoviePosterCell class]]) {
            ARNMoviePosterCell *posterCell = (ARNMoviePosterCell *)cell;
            if (posterCell.arnMovie != nil && [posterCell.arnMovie.page_number integerValue] >= 0) {
                // start a background fetch of new movies
                [[ARNArchiveController sharedInstance] fetchForCollection:self.collectionType withExclusion:self.collectionTypeExlusion andPageNumber:([posterCell.arnMovie.page_number integerValue] + 1) withRows:ARCHIVE_ORG_ROW_COUNT];
            }
        }
    }
}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout methods

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(80.0f, 80.0f, 80.0f, 80.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 30.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 20.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(256, 464);
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

// implementation is based on AFMasterViewController:
// https://github.com/ashfurrow/UICollectionView-NSFetchedResultsController/blob/459cd1c3b167fc8d368845e9ff7bbd40b8070630/AFMasterViewController.m
// the simplet looking code from blake water unfortunatelly crashed under heavy load (first start with multiple ongoing fetches)
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
    } completion:nil];
    
    self.objectChanges = nil;
    self.sectionChanges = nil;
}

- (void)dealloc {
    _fetchedResultsController.delegate = nil;
}

@end
