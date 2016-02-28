//
//  ARNFocusTextView.m
//  classicFilms
//
//  Created by Stefan Arn on 19/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//
// Based on https://gist.github.com/Cedrick84/8922a0af730c39c05794

#import "ARNFocusTextView.h"

@interface ARNFocusTextView ()
    @property(nonatomic, strong) UIVisualEffectView *visualEffectView;
    @property(nonatomic, strong) UIMotionEffectGroup *motionEffectGroup;
    @property(nonatomic, assign) BOOL isTouchable;
@end

@implementation ARNFocusTextView

- (instancetype)init {
    self = [super init];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self)
    {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        [self setup];
    }
    return self;
}

// common setup method used by init's
- (void)setup {
    // set default values
    [self isTouchable:YES];
    self.scrollEnabled = NO;
    self.clipsToBounds = NO;
    self.textContainerInset = UIEdgeInsetsMake(7.0f, 10.0f, 7.0f, 10.0f);
    self.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
    
    // background
    _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:UIBlurEffectStyleExtraLight];
    _visualEffectView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    _visualEffectView.frame = CGRectInset(self.bounds, -10, -10);
    _visualEffectView.alpha = 0;
    _visualEffectView.layer.cornerRadius = 5;
    _visualEffectView.clipsToBounds = YES;
    [self insertSubview:_visualEffectView atIndex:0];
    
    // tap recognizer
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(focusTextViewClicked:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // motion
    NSInteger motionRange = 5;
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-motionRange);
    verticalMotionEffect.maximumRelativeValue = @(motionRange);
    
    _motionEffectGroup = [UIMotionEffectGroup new];
    _motionEffectGroup.motionEffects = @[verticalMotionEffect];
}

- (void)isTouchable:(BOOL)touchable {
    self.isTouchable = touchable;
    self.selectable = touchable;
    self.userInteractionEnabled = touchable;
}


#pragma mark -
#pragma mark UITapGestureRecognizer methods

- (void)focusTextViewClicked:(UITapGestureRecognizer *)gesture {
    if (self.focusTextViewDelegate != nil) {
        [self.focusTextViewDelegate focusTextViewClicked];
    }
}


#pragma mark -
#pragma mark UIFocus methods

- (BOOL)canBecomeFocused {
    return self.isTouchable;
}

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    if (context.nextFocusedView == self) {
        [coordinator addCoordinatedAnimations:^{
            self.visualEffectView.alpha = 1;
            [self addMotionEffect:self.motionEffectGroup];
        } completion:nil];
    } else if (context.previouslyFocusedView == self) {
        [coordinator addCoordinatedAnimations:^{
            self.visualEffectView.alpha = 0;
            [self removeMotionEffect:self.motionEffectGroup];
        } completion:nil];
    }
}

@end
