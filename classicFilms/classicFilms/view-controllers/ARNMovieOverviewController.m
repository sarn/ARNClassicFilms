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
#import <AVKit/AVKit.h>

@interface ARNMovieOverviewController ()
    @property(nonatomic, strong) NSArray *movies;
    @property(nonatomic, strong) UICollectionView *collectionView;
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
    _movies = [NSArray array];
    _collectionType = [NSString string];
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
    
    // fetch the data
    [self refreshMovies];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshMovies) name:@"FetchMovieDataSuccessful" object:nil];
}

- (void)refreshMovies {
    self.movies = [[ARNMovieController sharedInstance] moviesForCollection:self.collectionType];
    [self.collectionView reloadData];
}


#pragma mark -
#pragma mark UICollectionViewDataSource methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.movies count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Setup cell identifier
    ARNMoviePosterCell *cell = (ARNMoviePosterCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"ARNMoviePosterCell" forIndexPath:indexPath];
    
    if (self.movies != nil && [self.movies count] > indexPath.row) {
        id obj = [self.movies objectAtIndex:indexPath.row];
        if (obj != nil) {
            if ([obj isKindOfClass:[ARNMovie class]]) {
                [cell configureCellWithMovie:(ARNMovie *)obj];
            }
        }
    }
    
    return cell;
}


#pragma mark -
#pragma mark UICollectionViewDelegate methods

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: implement
    
    if (self.movies != nil && [self.movies count] > indexPath.row) {
        id obj = [self.movies objectAtIndex:indexPath.row];
        if (obj != nil) {
            if ([obj isKindOfClass:[ARNMovie class]]) {
                ARNMovie *arnMovie = (ARNMovie *)obj;
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
