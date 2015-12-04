//
//  ARNMoviePosterCell.m
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMoviePosterCell.h"
#import "UIImageView+WebCache.h"
#import <AutoScrollLabel/CBAutoScrollLabel.h>


@interface ARNMoviePosterCell ()
    @property (nonatomic, strong) CBAutoScrollLabel *movieTitle;
    @property (nonatomic, strong) UIImageView *moviePoster;
    @property (nonatomic, strong) UIActivityIndicatorView *refreshActivityIndicator;
@end

@implementation ARNMoviePosterCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // data
        _arnMovie = nil;
        
        // customizations
        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
        
        CGFloat posterHeight = frame.size.width * 1.5;
        _moviePoster = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, posterHeight)];
        _moviePoster.contentMode = UIViewContentModeScaleAspectFit;
        _moviePoster.adjustsImageWhenAncestorFocused = YES;
        [self.contentView addSubview:_moviePoster];
        
        _movieTitle = [[CBAutoScrollLabel alloc] initWithFrame:CGRectMake(-40, posterHeight + 40, frame.size.width + 80, frame.size.height - posterHeight - 40)];
        _movieTitle.labelSpacing = 35; // distance between start and end labels
        _movieTitle.pauseInterval = 1.5; // seconds of pause before scrolling starts again
        _movieTitle.scrollSpeed = 30; // pixels per second
        _movieTitle.fadeLength = 20.0f; // length of the left and right edge fade, 0 to disable
        _movieTitle.textAlignment = NSTextAlignmentCenter;
        _movieTitle.font = [UIFont boldSystemFontOfSize:32.0f];
        _movieTitle.textColor = [UIColor whiteColor];
        _movieTitle.layer.shadowColor = [[UIColor blackColor] CGColor];
        _movieTitle.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
        _movieTitle.layer.shadowOpacity = 2.0f;
        _movieTitle.layer.shadowRadius = 2.0f;
        _movieTitle.alpha = 0.0;
        [self.contentView addSubview:_movieTitle];
        
        // activity indicator
        _refreshActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _refreshActivityIndicator.frame = CGRectMake(0, 0, frame.size.width, posterHeight);
        _refreshActivityIndicator.hidesWhenStopped = YES;
        [self.contentView addSubview:_refreshActivityIndicator];
    }
    return self;
}

- (void)prepareForReuse {
    self.movieTitle.text = [NSString string];
    self.movieTitle.alpha = 0.0;
    self.moviePoster.image = nil;
    self.arnMovie = nil;
}

- (void)configureCellWithMovie:(ARNMovie *)arnMovie {
    if (arnMovie != nil) {
        self.arnMovie = arnMovie;
        
        NSString *year = [NSString string];
        if ([arnMovie year] != nil) {
            year = [NSString stringWithFormat:@"(%@)", arnMovie.year];
        }
        
        NSString *title = [NSString string];
        if ([arnMovie.title length] > 0) {
            title = arnMovie.title;
        }
        
        NSString *fullPosterTitle = [NSString string];
        if ([title length] > 0 && [year length] > 0) {
            fullPosterTitle = [NSString stringWithFormat:@"%@ %@", title, year];
        } else if ([title length] > 0) {
            fullPosterTitle = title;
        } else if ([year length] > 0) {
            fullPosterTitle = year;
        }
        self.movieTitle.text = fullPosterTitle;

        if ([arnMovie.posterURL length] > 0) {
            NSString *completePosterURL = [NSString stringWithFormat:@"%@%@", @"https://image.tmdb.org/t/p/original", arnMovie.posterURL];
            [self.moviePoster sd_setImageWithURL:[NSURL URLWithString:completePosterURL]
        placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
    }
}

- (void)showActivityIndicator {
    self.moviePoster.alpha = 0.5;
    [self.refreshActivityIndicator startAnimating];
}

- (void)stopActivityIndicator {
    [self.refreshActivityIndicator stopAnimating];
    self.moviePoster.alpha = 1.0;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    /*
     Update the label's alpha value using the `UIFocusAnimationCoordinator`.
     This will ensure all animations run alongside each other when the focus
     changes.
     */
    [self.movieTitle refreshLabels];
    
    [coordinator addCoordinatedAnimations:^{
        if(self.focused) {
            self.movieTitle.alpha = 1.0;
        }
        else {
            self.movieTitle.alpha = 0.0;
        }
    } completion:nil];
}

@end
