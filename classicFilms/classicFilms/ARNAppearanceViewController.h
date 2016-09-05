//
//  ARNAppearanceViewController.h
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

#import <UIKit/UIKit.h>

@interface ARNAppearanceViewController : UIViewController

@property (nonatomic, assign) UIUserInterfaceStyle interfaceStyle;
- (void)setViewController:(UIViewController *)viewController;

@end
