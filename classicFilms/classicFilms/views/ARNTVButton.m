//
//  ARNTVButton.m
//  classicFilms
//
//  Created by Stefan Arn on 27/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//

#import "ARNTVButton.h"

@interface ARNTVButton ()
    @property(nonatomic, strong) UIMotionEffectGroup *motionEffectGroup;
@end

@implementation ARNTVButton

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
    // add vertical and horizontal motion on touch
    NSInteger motionRange = 5;
    
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    verticalMotionEffect.minimumRelativeValue = @(-motionRange);
    verticalMotionEffect.maximumRelativeValue = @(motionRange);
    
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-motionRange);
    horizontalMotionEffect.maximumRelativeValue = @(motionRange);
    
    self.motionEffectGroup = [UIMotionEffectGroup new];
    self.motionEffectGroup.motionEffects = @[verticalMotionEffect, horizontalMotionEffect];
    
    [self addMotionEffect:self.motionEffectGroup];
}


#pragma mark -
#pragma mark UIFocus methods

- (void)didUpdateFocusInContext:(UIFocusUpdateContext *)context withAnimationCoordinator:(UIFocusAnimationCoordinator *)coordinator {
    if (context.nextFocusedView == self) {
        [coordinator addCoordinatedAnimations:^{
            [self addMotionEffect:self.motionEffectGroup];
        } completion:nil];
    } else if (context.previouslyFocusedView == self) {
        [coordinator addCoordinatedAnimations:^{
            [self removeMotionEffect:self.motionEffectGroup];
        } completion:nil];
    }
}

@end
