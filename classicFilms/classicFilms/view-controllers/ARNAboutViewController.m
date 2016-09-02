//
//  ARNAboutViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 06/11/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNAboutViewController.h"

@interface ARNAboutViewController ()
    @property (nonatomic, strong) UIImageView *internetArchiveImageView;
    @property (nonatomic, strong) UIImageView *tmdbImageView;
    @property (nonatomic, strong) UILabel *internetArchiveLabel;
    @property (nonatomic, strong) UILabel *tmdbLabel;
@end

@implementation ARNAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // attribution images
    UIImage *internetArchiveImage = [[UIImage imageNamed:@"internet_archive"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    CGRect internetArchiveImageViewFrame = CGRectMake(((self.view.frame.size.width / 2) - internetArchiveImage.size.width) / 2, 220.0f, internetArchiveImage.size.width, internetArchiveImage.size.height);
    self.internetArchiveImageView = [[UIImageView alloc] initWithFrame:internetArchiveImageViewFrame];
    self.internetArchiveImageView.image = internetArchiveImage;
    self.internetArchiveImageView.tintColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
    [self.view addSubview:self.internetArchiveImageView];

    UIImage *tmdbImage = [[UIImage imageNamed:@"tmdb"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]; // rendering mode "template" enables tint coloring
    CGRect tmdbImageViewFrame = CGRectMake(((self.view.frame.size.width / 2) - tmdbImage.size.width) / 2 + 40.0f, internetArchiveImageViewFrame.origin.y + internetArchiveImageViewFrame.size.height + 120.0f, tmdbImage.size.width, tmdbImage.size.height);
    self.tmdbImageView = [[UIImageView alloc] initWithFrame:tmdbImageViewFrame];
    self.tmdbImageView.image = tmdbImage;
    self.tmdbImageView.tintColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
    [self.view addSubview:self.tmdbImageView];
    
    // attribution labels
    CGFloat xLabelInset = MAX(internetArchiveImageViewFrame.origin.x + internetArchiveImageViewFrame.size.width, tmdbImageViewFrame.origin.x + tmdbImageViewFrame.size.width);
    
    self.internetArchiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelInset + 80.0f, internetArchiveImageViewFrame.origin.y, self.view.frame.size.width - (xLabelInset + 80.0f) - 150.0f, internetArchiveImageViewFrame.size.height)];
    self.internetArchiveLabel.backgroundColor = [UIColor clearColor];
    self.internetArchiveLabel.numberOfLines = 0;
    self.internetArchiveLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.internetArchiveLabel.font = [UIFont systemFontOfSize:32.0f];
    self.internetArchiveLabel.textColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
    self.internetArchiveLabel.text = NSLocalizedString(@"about_internet_archive", nil);
    [self.view addSubview:self.internetArchiveLabel];
    
    self.tmdbLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelInset + 80.0f, tmdbImageViewFrame.origin.y, self.view.frame.size.width - (xLabelInset + 80.0f) - 150.0f, tmdbImageViewFrame.size.height)];
    self.tmdbLabel.backgroundColor = [UIColor clearColor];
    self.tmdbLabel.numberOfLines = 0;
    self.tmdbLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.tmdbLabel.font = [UIFont systemFontOfSize:32.0f];
    self.tmdbLabel.textColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
    self.tmdbLabel.text = NSLocalizedString(@"about_tmdb", nil);
    [self.view addSubview:self.tmdbLabel];
    
    // git source
    UILabel *gitLabel = [[UILabel alloc] initWithFrame:CGRectMake(internetArchiveImageViewFrame.origin.x, tmdbImageViewFrame.origin.y + tmdbImageViewFrame.size.height, self.view.frame.size.width - internetArchiveImageViewFrame.origin.x - 150.0f, self.view.frame.size.height - (tmdbImageViewFrame.origin.y + tmdbImageViewFrame.size.height))];
    gitLabel.backgroundColor = [UIColor clearColor];
    gitLabel.numberOfLines = 0;
    gitLabel.lineBreakMode = NSLineBreakByWordWrapping;
    gitLabel.textAlignment = NSTextAlignmentCenter;
    gitLabel.font = [UIFont systemFontOfSize:28.0f];
    gitLabel.textColor = [UIColor grayColor];
    gitLabel.text = NSLocalizedString(@"about_project", nil);
    [self.view addSubview:gitLabel];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // did the userInterfaceStyle change?
    if (previousTraitCollection != nil && self.traitCollection.userInterfaceStyle != previousTraitCollection.userInterfaceStyle) {
        // set correct colors for UI elements
        self.internetArchiveImageView.tintColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
        self.tmdbImageView.tintColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
        self.internetArchiveLabel.textColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
        self.tmdbLabel.textColor = (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) ? [UIColor lightGrayColor] : [UIColor blackColor];
    }
}

@end
