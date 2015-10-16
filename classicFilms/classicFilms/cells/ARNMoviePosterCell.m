//
//  ARNMoviePosterCell.m
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNMoviePosterCell.h"

@interface ARNMoviePosterCell ()
    @property (nonatomic, strong) UILabel *movieTitle;
    @property (nonatomic, strong) UIImageView *moviePoster;
@end

@implementation ARNMoviePosterCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:frame];
        backgroundView.backgroundColor = [UIColor clearColor];
        backgroundView.layer.borderColor = [UIColor grayColor].CGColor;
        backgroundView.layer.borderWidth = 1.0f;
        self.backgroundView = backgroundView;
        
        // customizations
        
//        _moviePoster = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        _moviePoster.contentMode = UIViewContentModeScaleAspectFill;
//        _moviePoster.adjustsImageWhenAncestorFocused = YES;
//        [self.contentView addSubview:_moviePoster];
        
        _movieTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _movieTitle.alpha = 0.0f;
        [self.contentView addSubview:_movieTitle];
        
        
    }
    return self;
}

- (void)prepareForReuse {
    self.movieTitle.alpha = 0.0;
}

- (void)configureCellWithMovie:(ARNMovie *)arnMovie {
//    if (image != nil) {
//        [self.moviePoster setImage:image];
//    }
    
    // TODO: get the image from the background async download or show placeholder and replace later on

    if (arnMovie != nil) {
        self.movieTitle.text = ([arnMovie.title length] > 0) ? arnMovie.title : [NSString string];
        self.movieTitle.backgroundColor = [UIColor clearColor];
    }
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    /*
     Update the label's alpha value using the `UIFocusAnimationCoordinator`.
     This will ensure all animations run alongside each other when the focus
     changes.
     */
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
