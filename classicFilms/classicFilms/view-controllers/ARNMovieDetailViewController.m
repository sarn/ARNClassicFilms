//
//  ARNMovieDetailViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 12/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//

#import "ARNMovieDetailViewController.h"
#import "ARNTextViewController.h"
#import "ARNTVButton.h"
#import "UIImageView+WebCache.h"
#import <AVKit/AVKit.h>

@interface ARNMovieDetailViewController ()
    @property(nonatomic, strong) AVPlayer *player;
    @property(nonatomic, strong) ARNFocusTextView *descriptionTextView;
    @property(nonatomic, strong) UIButton *playMovieButton;
@end

@implementation ARNMovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // --  preload movie --
    [self loadMovie];
    
    // -- UI components --
    NSString *completePosterURL = [NSString string];
    if (self.arnMovie != nil && [self.arnMovie.posterURL length] > 0) {
        completePosterURL = [NSString stringWithFormat:@"%@%@", @"https://image.tmdb.org/t/p/original", self.arnMovie.posterURL];
    }
    
    // background
    if ([completePosterURL length] > 0) {
        UIImageView *backdrop = [[UIImageView alloc] initWithFrame:self.view.frame];
        backdrop.contentMode = UIViewContentModeScaleAspectFill;
        [backdrop sd_setImageWithURL:[NSURL URLWithString:completePosterURL] placeholderImage:nil];
        
        UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        visualEffectView.frame = self.view.frame;
        [backdrop addSubview:visualEffectView];
        
        [self.view addSubview:backdrop];
    }
    
    // title
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200.0f, 72.0f, self.view.frame.size.width - 940.0f, 200.0f)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.numberOfLines = 0;
    titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    titleLabel.font = [UIFont boldSystemFontOfSize:56.0f];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = (self.arnMovie != nil && [self.arnMovie.title length] > 0) ? self.arnMovie.title : @"-";
    titleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    titleLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    titleLabel.layer.shadowOpacity = 2.0f;
    titleLabel.layer.shadowRadius = 2.0f;
    [titleLabel sizeToFit];
    
    // title bottom alignment
    CGRect titleFrame = titleLabel.frame;
    titleFrame.origin.y = 208.0f - titleLabel.frame.size.height;
    titleLabel.frame = titleFrame;
    [self.view addSubview:titleLabel];
    
    // optional original title
    float metaDataLabelFrameYOffset = titleLabel.frame.origin.y + titleLabel.frame.size.height;
    if (self.arnMovie != nil && [self.arnMovie.original_title length] > 0) {
        UILabel *originalTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + 2.0f, titleLabel.frame.origin.y + titleLabel.frame.size.height, self.view.frame.size.width - 940.0f, 40.0f)];
        originalTitleLabel.backgroundColor = [UIColor clearColor];
        originalTitleLabel.font = [UIFont boldSystemFontOfSize:32.0f];
        originalTitleLabel.textColor = [UIColor whiteColor];
        originalTitleLabel.text = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"original_title", nil), self.arnMovie.original_title];
        originalTitleLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
        originalTitleLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        originalTitleLabel.layer.shadowOpacity = 2.0f;
        originalTitleLabel.layer.shadowRadius = 2.0f;
        [self.view addSubview:originalTitleLabel];
        
        metaDataLabelFrameYOffset = originalTitleLabel.frame.origin.y + originalTitleLabel.frame.size.height;
    }
    
    // meta data (runtime, year, ...)
    NSString *emptyPadding = @"        ";
    NSMutableString *metaDataString = [NSMutableString string];
    
    [metaDataString appendString:NSLocalizedString(self.arnMovie.collection, nil)];
    
    if ([self.arnMovie.runtime integerValue] > 0) {
        [metaDataString appendString:emptyPadding];
        
        NSInteger totalSeconds = [self.arnMovie.runtime integerValue];
        NSInteger hours = floor(totalSeconds / 3600);
        NSInteger minutes = floor(totalSeconds % 3600 / 60);
        
        NSMutableString *durationText = [NSMutableString string];
        if (hours > 1) {
            [durationText appendString:[NSString stringWithFormat:@"%lu hrs ", (long)hours]];
        } else if (hours > 0) {
            [durationText appendString:[NSString stringWithFormat:@"%lu hr ", (long)hours]];
        }
        [durationText appendString:[NSString stringWithFormat:@"%lu min", (long)minutes]];
        
        [metaDataString appendString:[NSString stringWithFormat:@"%@", durationText]];
    }
    
    [metaDataString appendString:emptyPadding];
    [metaDataString appendString:[NSString stringWithFormat:@"%@", [self.arnMovie.year stringValue]]];
    
    if ([self.arnMovie.tmdb_rating doubleValue] > 0) {
        [metaDataString appendString:emptyPadding];
        [metaDataString appendString:[NSString stringWithFormat:@"tmdb rating: %.01f", [self.arnMovie.tmdb_rating doubleValue]]];
    }
    
    if ([self.arnMovie.imdb_rating doubleValue] > 0) {
        [metaDataString appendString:emptyPadding];
        [metaDataString appendString:[NSString stringWithFormat:@"imdb rating: %.01f", [self.arnMovie.imdb_rating doubleValue]]];
    }
    
    UILabel *metaDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x + 2.0f, metaDataLabelFrameYOffset + 30.0f, self.view.frame.size.width - 940.0f, 40.0f)];
    metaDataLabel.backgroundColor = [UIColor clearColor];
    metaDataLabel.font = [UIFont systemFontOfSize:24.0f];
    metaDataLabel.textColor = [UIColor whiteColor];
    metaDataLabel.text = metaDataString;
    metaDataLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    metaDataLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    metaDataLabel.layer.shadowOpacity = 2.0f;
    metaDataLabel.layer.shadowRadius = 2.0f;
    [self.view addSubview:metaDataLabel];
    
    // description
    self.descriptionTextView = [[ARNFocusTextView alloc] initWithFrame:CGRectMake(titleLabel.frame.origin.x - 14.0f, metaDataLabel.frame.origin.y + metaDataLabel.frame.size.height + 20.0f, self.view.frame.size.width - 924.0f, 207.0f)];
    self.descriptionTextView.backgroundColor = [UIColor clearColor];
    self.descriptionTextView.font = [UIFont boldSystemFontOfSize:32.0f];
    self.descriptionTextView.textContainer.maximumNumberOfLines = 5;
    self.descriptionTextView.textColor = [UIColor whiteColor];
    self.descriptionTextView.text = self.arnMovie.movie_description;
    self.descriptionTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.descriptionTextView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.descriptionTextView.layer.shadowOpacity = 2.0f;
    self.descriptionTextView.layer.shadowRadius = 2.0f;
    self.descriptionTextView.focusTextViewDelegate = self;
    [self.view addSubview:self.descriptionTextView];
    
    // We need to enable touch if the text in the focus text view is truncated.
    // A touch on the view shows the full text.
    // We disable touch if the text fits the focus text view.
    // Otherwise we would confuse the user with a not needed user interaction.
    [self.descriptionTextView isTouchable:[self isFocusTextViewTruncated]];
    
    // play button
    UIImage *playImage = [UIImage imageNamed:@"play"];
    self.playMovieButton = [ARNTVButton buttonWithType:UIButtonTypeSystem];
    self.playMovieButton.frame = CGRectMake(titleLabel.frame.origin.x + 2.0f, self.descriptionTextView.frame.origin.y + self.descriptionTextView.frame.size.height + 40.0f, 125.0f, 75.0f);
    [self.playMovieButton setImage:playImage forState:UIControlStateNormal];
    [self.playMovieButton addTarget:self action:@selector(playMovie) forControlEvents:UIControlEventPrimaryActionTriggered];
    [self.view addSubview:self.playMovieButton];
    
    // play button label
    UILabel *playLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.playMovieButton.frame.origin.x, self.playMovieButton.frame.origin.y + self.playMovieButton.frame.size.height + 5.0f, self.playMovieButton.frame.size.width, 40.0f)];
    playLabel.backgroundColor = [UIColor clearColor];
    playLabel.font = [UIFont boldSystemFontOfSize:24.0f];
    playLabel.textColor = [UIColor whiteColor];
    playLabel.text = NSLocalizedString(@"play", nil);
    playLabel.textAlignment = NSTextAlignmentCenter;
    playLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    playLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    playLabel.layer.shadowOpacity = 2.0f;
    playLabel.layer.shadowRadius = 2.0f;
    [self.view addSubview:playLabel];
    
    // poster
    if ([completePosterURL length] > 0) {
        UIImageView *moviePoster = [[UIImageView alloc] initWithFrame:CGRectMake(1227.0f, 61.0f, 590.0f, 787.0f)];
        moviePoster.contentMode = UIViewContentModeScaleAspectFit;
        [moviePoster sd_setImageWithURL:[NSURL URLWithString:completePosterURL]
                       placeholderImage:[UIImage imageNamed:@"placeholder"]];
        moviePoster.backgroundColor = [UIColor clearColor];
        [self.view addSubview:moviePoster];
    }
}

- (void)loadMovie {
    if (self.arnMovie != nil && [self.arnMovie.source length] > 0) {
        // open the stream
        // https://archive.org/download/night_of_the_living_dead/night_of_the_living_dead_512kb.mp4
        NSString *videoStream = [NSString stringWithFormat:@"%@%@/%@", @"https://archive.org/download/", self.arnMovie.archive_id, self.arnMovie.source];
        NSURL *videoURL = [NSURL URLWithString:videoStream];
        
        // start the player
        self.player = [AVPlayer playerWithURL:videoURL];
        
        // subscribe to be informed about a finished playback
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    }
}

- (void)playMovie {
    if (self.player != nil && self.arnMovie != nil && [self.arnMovie.source length] > 0) {
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        [self presentViewController:playerViewController animated:YES completion:^{
            playerViewController.player = self.player;
            [self.player play];
        }];
    }
}

- (void)itemDidPlayToEnd:(NSNotification *)notification {
    // will be called when AVPlayer finishes playing
    if(self.presentedViewController != nil && [self.presentedViewController isKindOfClass:[AVPlayerViewController class]]) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:^{
            // reset the player to the start of the video.
            // we do this to prevent the following behaviour:
            // if an user starts the movie a second time we would
            // still be at the end and dismiss ourselves immediately.
            // the user would not be able to start the video again.
            if (self.player != nil) {
                [self.player seekToTime:CMTimeMakeWithSeconds(0.0f, 1)];
            }
        }];
    }
}

- (BOOL)isFocusTextViewTruncated {
    BOOL isFocusTextViewTruncated = NO;
    
    // we need to calculate the "actualPageWidth" as described here:http://stackoverflow.com/a/25941139/956433
    CGFloat padding = self.descriptionTextView.textContainer.lineFragmentPadding;
    CGFloat actualPageWidth = self.descriptionTextView.textContainer.size.width - padding * 2;
    
    CGSize textSize = [self.descriptionTextView.text boundingRectWithSize:CGSizeMake(actualPageWidth, CGFLOAT_MAX)
                                                                  options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                               attributes:@{NSFontAttributeName:self.descriptionTextView.font}
                                                                  context:nil].size;
    
    if (ceilf(textSize.height) > (self.descriptionTextView.textContainer.size.height)) {
        isFocusTextViewTruncated = YES;
    }

    return isFocusTextViewTruncated;
}


#pragma mark -
#pragma mark UIFocus methods

- (UIView *)preferredFocusedView {
    // focus the play button initially
    return self.playMovieButton;
}


#pragma mark -
#pragma mark ARNFocusTextView delegate methods

- (void)focusTextViewClicked {
    ARNTextViewController *textViewController = [ARNTextViewController new];
    textViewController.label.text = self.arnMovie.movie_description;
    textViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:textViewController animated:YES completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.descriptionTextView.focusTextViewDelegate = nil;
}

@end
