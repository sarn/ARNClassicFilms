//
//  ARNAboutViewController.m
//  classicFilms
//
//  Created by Stefan Arn on 06/11/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNAboutViewController.h"

@interface ARNAboutViewController ()

@end

@implementation ARNAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // attribution images
    UIImage *internetArchiveImage = [UIImage imageNamed:@"internet_archive"];
    CGRect internetArchiveImageViewFrame = CGRectMake(((self.view.frame.size.width / 2) - internetArchiveImage.size.width) / 2, 220.0f, internetArchiveImage.size.width, internetArchiveImage.size.height);
    UIImageView *internetArchiveImageView = [[UIImageView alloc] initWithFrame:internetArchiveImageViewFrame];
    internetArchiveImageView.image = internetArchiveImage;
    [self.view addSubview:internetArchiveImageView];

    UIImage *tmdbImage = [UIImage imageNamed:@"tmdb"];
    CGRect tmdbImageViewFrame = CGRectMake(((self.view.frame.size.width / 2) - tmdbImage.size.width) / 2 + 40.0f, internetArchiveImageViewFrame.origin.y + internetArchiveImageViewFrame.size.height + 120.0f, tmdbImage.size.width, tmdbImage.size.height);
    UIImageView *tmdbImageView = [[UIImageView alloc] initWithFrame:tmdbImageViewFrame];
    tmdbImageView.image = tmdbImage;
    [self.view addSubview:tmdbImageView];
    
    // attribution labels
    CGFloat xLabelInset = MAX(internetArchiveImageViewFrame.origin.x + internetArchiveImageViewFrame.size.width, tmdbImageViewFrame.origin.x + tmdbImageViewFrame.size.width);
    
    UILabel *internetArchiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelInset + 80.0f, internetArchiveImageViewFrame.origin.y, self.view.frame.size.width - (xLabelInset + 80.0f) - 150.0f, internetArchiveImageViewFrame.size.height)];
    internetArchiveLabel.backgroundColor = [UIColor clearColor];
    internetArchiveLabel.numberOfLines = 0;
    internetArchiveLabel.lineBreakMode = NSLineBreakByWordWrapping;
    internetArchiveLabel.font = [UIFont systemFontOfSize:32.0f];
    internetArchiveLabel.textColor = [UIColor blackColor];
    internetArchiveLabel.text = NSLocalizedString(@"about_internet_archive", nil);
    [self.view addSubview:internetArchiveLabel];
    
    UILabel *tmdbLabel = [[UILabel alloc] initWithFrame:CGRectMake(xLabelInset + 80.0f, tmdbImageViewFrame.origin.y, self.view.frame.size.width - (xLabelInset + 80.0f) - 150.0f, tmdbImageViewFrame.size.height)];
    tmdbLabel.backgroundColor = [UIColor clearColor];
    tmdbLabel.numberOfLines = 0;
    tmdbLabel.lineBreakMode = NSLineBreakByWordWrapping;
    tmdbLabel.font = [UIFont systemFontOfSize:32.0f];
    tmdbLabel.textColor = [UIColor blackColor];
    tmdbLabel.text = NSLocalizedString(@"about_tmdb", nil);
    [self.view addSubview:tmdbLabel];
    
    // git source
    UILabel *gitLabel = [[UILabel alloc] initWithFrame:CGRectMake(internetArchiveImageViewFrame.origin.x, tmdbImageViewFrame.origin.y + tmdbImageViewFrame.size.height, self.view.frame.size.width - internetArchiveImageViewFrame.origin.x - 150.0f, self.view.frame.size.height - (tmdbImageViewFrame.origin.y + tmdbImageViewFrame.size.height))];
    gitLabel.backgroundColor = [UIColor clearColor];
    gitLabel.numberOfLines = 0;
    gitLabel.lineBreakMode = NSLineBreakByWordWrapping;
    gitLabel.textAlignment = NSTextAlignmentCenter;
    gitLabel.font = [UIFont systemFontOfSize:28.0f];
    gitLabel.textColor = [UIColor blackColor];
    gitLabel.text = NSLocalizedString(@"about_project", nil);
    [self.view addSubview:gitLabel];
}

@end
