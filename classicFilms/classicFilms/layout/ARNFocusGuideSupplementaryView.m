//
//  ARNFocusGuideSupplementaryView.m
//  classicFilms
//
//  Created by Stefan Arn on 11/03/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//

#import "ARNFocusGuideSupplementaryView.h"

@interface ARNFocusGuideSupplementaryView ()
    @property (nonatomic, strong) UIFocusGuide *focusGuide;
@end

@implementation ARNFocusGuideSupplementaryView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        // focus guide
        _focusGuide = [UIFocusGuide new];
        _focusGuide.enabled = NO;
        [self addLayoutGuide:_focusGuide];
        
        [self.leadingAnchor constraintEqualToAnchor:_focusGuide.leadingAnchor].active = YES;
        [self.trailingAnchor constraintEqualToAnchor:_focusGuide.trailingAnchor].active = YES;
        [self.topAnchor constraintEqualToAnchor:_focusGuide.topAnchor].active = YES;
        [self.bottomAnchor constraintEqualToAnchor:_focusGuide.bottomAnchor].active = YES;
    }
    return self;
}

- (void)configureViewWithPreferredFocusedView:(UIView *)preferredFocusedView {
    if (preferredFocusedView != nil) {
        self.focusGuide.preferredFocusedView = preferredFocusedView;
        self.focusGuide.enabled = YES;
    } else {
        self.focusGuide.enabled = NO;
    }
}

@end
