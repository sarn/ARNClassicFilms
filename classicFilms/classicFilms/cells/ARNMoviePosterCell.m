//
//  ARNMoviePosterCell.m
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMoviePosterCell.h"
#import "UIImageView+AFNetworking.h"

@interface ARNMoviePosterCell ()
    @property (nonatomic, strong) UILabel *movieTitle;
    @property (nonatomic, strong) UIImageView *moviePoster;
@end

@implementation ARNMoviePosterCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // data
        _pageNumber = -1;
        
        // customizations
        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor clearColor];
        self.backgroundView = backgroundView;
        
        CGFloat posterHeight = frame.size.width * 1.5;
        _moviePoster = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, posterHeight)];
        _moviePoster.contentMode = UIViewContentModeScaleAspectFit;
        _moviePoster.adjustsImageWhenAncestorFocused = YES;
        [self.contentView addSubview:_moviePoster];
        
        _movieTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, posterHeight + 40, frame.size.width, frame.size.height - posterHeight - 40)];
        _movieTitle.lineBreakMode = NSLineBreakByWordWrapping;
        _movieTitle.numberOfLines = 0;
        _movieTitle.textAlignment = NSTextAlignmentCenter;
        _movieTitle.font = [UIFont boldSystemFontOfSize:36.0f];
        [self.contentView addSubview:_movieTitle];
    }
    return self;
}

- (void)prepareForReuse {
    self.movieTitle.text = [NSString string];
    self.moviePoster.image = nil;
}

- (void)configureCellWithMovie:(ARNMovie *)arnMovie {
    if (arnMovie != nil) {
        // each cell knows to which page call she belongs
        // we use this to start a new call for the next page
        // if we are close  to the end of the list
        self.pageNumber = [arnMovie.page_number integerValue];
        
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
        self.movieTitle.backgroundColor = [UIColor clearColor];
        [self.movieTitle sizeToFit]; // align to the top
        // align to the center
        CGRect myFrame = self.movieTitle.frame;
        myFrame = CGRectMake(myFrame.origin.x, myFrame.origin.y, self.frame.size.width, myFrame.size.height);
        self.movieTitle.frame = myFrame;
        
        
        if ([arnMovie.posterURL length] > 0) {
            NSString *completePosterURL = [NSString stringWithFormat:@"%@%@", @"https://image.tmdb.org/t/p/original", arnMovie.posterURL];
            [self.moviePoster setImageWithURL:[NSURL URLWithString:completePosterURL] placeholderImage:[UIImage imageNamed:@"placeholder"]];
        }
    }
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    /*
     Update the label's alpha value using the `UIFocusAnimationCoordinator`.
     This will ensure all animations run alongside each other when the focus
     changes.
     */
//    [coordinator addCoordinatedAnimations:^{
//        if(self.focused) {
//            self.movieTitle.alpha = 1.0;
//        }
//        else {
//            self.movieTitle.alpha = 0.0;
//        }
//    } completion:nil];
}

@end
