//
//  ARNMoviePosterCell.h
//  classicFilms
//
//  Created by Stefan Arn on 16/10/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARNMovie.h"

@interface ARNMoviePosterCell : UICollectionViewCell

@property (nonatomic, strong) ARNMovie *arnMovie;
- (void)configureCellWithMovie:(ARNMovie *)arnMovie;
- (void)showActivityIndicator;
- (void)stopActivityIndicator;

@end
