//
//  ARNMovieDetailViewController.h
//  classicFilms
//
//  Created by Stefan Arn on 12/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARNMovie.h"
#import "ARNFocusTextView.h"

@interface ARNMovieDetailViewController : UIViewController <ARNFocusTextViewDelegate>

@property(nonatomic, strong) ARNMovie *arnMovie;

@end
