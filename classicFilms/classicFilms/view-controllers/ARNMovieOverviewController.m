//
//  FirstViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 11/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMovieOverviewController.h"
#import "ARNMovieController.h"
#import "ARNMoviePosterCell.h"
#import "ARNMovie.h"
#import "Movie.h"
#import "AppDelegate.h"
#import <AVKit/AVKit.h>

@interface ARNMovieOverviewController ()
    //@property(nonatomic, strong) NSArray *movies;
    @property(nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
    @property(nonatomic, strong) UICollectionView *collectionView;
    @property(nonatomic, strong) UIActivityIndicatorView *refreshActivityIndicator;
    @property(nonatomic, strong) NSBlockOperation *blockOperation;
    @property(nonatomic, assign) BOOL shouldReloadCollectionView;
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
    //_movies = [NSArray array];
    _collectionType = [NSString string];
    _shouldReloadCollectionView = NO;
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
    //self.collectionView.maskView = // TODO: copy this feature from apple example project
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
    //[self.view addSubview:self.refreshActivityIndicator];
    [self.refreshActivityIndicator startAnimating];
    
    // set up the fetcher for the data
    [[self fetchedResultsController] performFetch:nil];
    
    //[self refreshMovies];
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMovies) name:@"FetchMovieDataSuccessful" object:nil];
}

//- (void)refreshMovies {
//    self.movies = [[ARNMovieController sharedInstance] moviesForCollection:self.collectionType];
//    
//    if ([self.movies count] > 0) {
//        [self.refreshActivityIndicator stopAnimating];
//    }
//    [self.collectionView reloadData];
//}

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
                                                                                 [NSPredicate predicateWithFormat:@"tmdb_id.length > 0"],
                                                                                 [NSPredicate predicateWithFormat:@"title.length > 0"],
                                                                                 [NSPredicate predicateWithFormat:@"posterURL.length > 0"],
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id sectionInfo = [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
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
    // TODO: implement
    
    id obj = [_fetchedResultsController objectAtIndexPath:indexPath];
    if (obj != nil) {
        if ([obj isKindOfClass:[Movie class]]) {
            ARNMovie *arnMovie = [[ARNMovie alloc] initWithAttributesOfManagedObject:obj];
            if ([arnMovie.source length] > 0) {
                // open the stream
                //https://archive.org/download/night_of_the_living_dead/night_of_the_living_dead_512kb.mp4
                NSString *videoStream = [NSString stringWithFormat:@"%@%@/%@", @"https://archive.org/download/", arnMovie.archive_id, arnMovie.source];
                
                NSURL *videoURL = [NSURL URLWithString:videoStream];
                AVPlayer *player = [AVPlayer playerWithURL:videoURL];
                
                AVPlayerViewController *playerViewController = [AVPlayerViewController new];
                playerViewController.player = player;
                [self presentViewController:playerViewController animated:YES completion:nil];
                
                
                
                
                // instantiate here or in storyboard
                //                    AVPlayerViewController *viewController = [[AVPlayerViewController alloc] initWithNibName:nil bundle:nil];
                //                    viewController.player = player;
                //
                //                    [self addChildViewController:viewController];
                //                    [self.view addSubview:viewController.view];
                //                    [viewController didMoveToParentViewController:self];
                [player play];
                
                
            }
        }
    }
}


#pragma mark -
#pragma mark UICollectionViewDelegateFlowLayout methods

-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(100.0f, 50.0f, 100.0f, 50.0f);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 50.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 40.0f;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(400, 850);
}


#pragma mark -
#pragma mark NSFetchedResultsControllerDelegate methods

// implementation is based on gist: https://gist.github.com/iwasrobbed/5528897
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    self.shouldReloadCollectionView = NO;
    self.blockOperation = [[NSBlockOperation alloc] init];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex]];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            if ([self.collectionView numberOfSections] > 0) {
                if ([self.collectionView numberOfItemsInSection:indexPath.section] == 0) {
                    self.shouldReloadCollectionView = YES;
                } else {
                    [self.blockOperation addExecutionBlock:^{
                        [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
                    }];
                }
            } else {
                self.shouldReloadCollectionView = YES;
            }
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            if ([self.collectionView numberOfItemsInSection:indexPath.section] == 1) {
                self.shouldReloadCollectionView = YES;
            } else {
                [self.blockOperation addExecutionBlock:^{
                    [collectionView deleteItemsAtIndexPaths:@[indexPath]];
                }];
            }
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }];
            break;
        }
            
        case NSFetchedResultsChangeMove: {
            [self.blockOperation addExecutionBlock:^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            }];
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
    if (self.shouldReloadCollectionView) {
        [self.collectionView reloadData];
    } else {
        [self.collectionView performBatchUpdates:^{
            [self.blockOperation start];
        } completion:nil];
    }
}

- (void)dealloc {
    //[[NSNotificationCenter defaultCenter] removeObserver:self];
    _fetchedResultsController.delegate = nil;
}

@end
