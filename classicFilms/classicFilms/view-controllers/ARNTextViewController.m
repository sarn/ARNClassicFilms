//
//  ARNTextViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 19/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//

#import "ARNTextViewController.h"

@interface ARNTextViewController ()

@end

@implementation ARNTextViewController

- (instancetype)init {
    self = [super init];
    if(self)
    {
        [self setup];
    }
    return self;
}

// common setup method used by init's
- (void)setup {
    // background
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.frame;
    [self.view addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [self.view addSubview:vibrancyEffectView];
    
    // label
    double labelWidth = self.view.frame.size.width - 944.0f; // imitates the focus text view width for better readability
    double sidePadding = (self.view.frame.size.width - labelWidth) / 2.0f;
    _label = [[UILabel alloc] initWithFrame:CGRectMake(sidePadding, 0.0, labelWidth, self.view.frame.size.height)];
    _label.backgroundColor = [UIColor clearColor];
    _label.font = [UIFont boldSystemFontOfSize:32.0f];
    _label.lineBreakMode = NSLineBreakByWordWrapping;
    _label.numberOfLines = 0;
    _label.textAlignment = NSTextAlignmentLeft;
    _label.textColor = [UIColor whiteColor];
    _label.layer.shadowColor = [[UIColor blackColor] CGColor];
    _label.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _label.layer.shadowOpacity = 2.0f;
    _label.layer.shadowRadius = 2.0f;
    [self.view addSubview:_label];
}

@end
