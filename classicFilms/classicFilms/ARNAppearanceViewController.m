//
//  ARNAppearanceViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 05/09/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//
//  This view controller allows to enforce a light or dark
//  UI interface style theme on a single UIViewController without
//  respecting the system default. So you can use it to create
//  a system style exception for a specific UIViewController
//
//  This code is based on the WWDC 2016 Session 206 and the
//  code found here: https://github.com/ios8/AdaptivePhotosAnAdaptiveApplication/blob/master/AdaptivePhotos/AAPLTraitOverrideViewController.m

#import "ARNAppearanceViewController.h"

@interface ARNAppearanceViewController ()
    @property (nonatomic, strong) UIViewController *childViewController;
@end

@implementation ARNAppearanceViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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

- (void)setup {
    // set a default interface style
    self.interfaceStyle = UIUserInterfaceStyleLight;
}

- (void)setViewController:(UIViewController *)viewController {
    if (viewController != nil) {
        self.childViewController = viewController;
        
        // override trait collection
        UITraitCollection *traitCollection = [UITraitCollection traitCollectionWithUserInterfaceStyle:self.interfaceStyle];
        [self setOverrideTraitCollection:traitCollection forChildViewController:self.childViewController];
        
        // add child view controller
        [self addChildViewController:self.childViewController];
        self.childViewController.view.frame = self.view.bounds;
        [self.view addSubview:self.childViewController.view];
        [self.childViewController didMoveToParentViewController:self];
    }
}

- (UIView *)preferredFocusedView {
    if (self.childViewController != nil) {
        return [self.childViewController preferredFocusedView];
    } else {
        return self.view;
    }
}

@end
