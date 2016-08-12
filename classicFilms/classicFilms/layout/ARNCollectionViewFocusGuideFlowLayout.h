//
//  ARNCollectionViewFocusGuideFlowLayout.h
//  classicFilms
//
//  Created by Stefan Arn on 11/03/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//
//  A custom flow layout that places FocusGuides into the
//  empty spots of the grid (where no cell exists)
//  Thus helping the focus engine to direct the focus to the correct cell
//
//  This is based on the ideas described here
//  http://stackoverflow.com/questions/34120558/custom-focus-engine-behaviour-for-uicollectionview
//  and here https://forums.developer.apple.com/message/93020
//
//  We need to use a custom FlowLayout to get rid of a known bug in the
//  standard UICollectionViewFlowLayout (radar bug #26803196 & #22392869)
//
//  Apple Engineering replied the following:
//  "The 'moves down even if nothing is directly beneath it' rule only works
//  within the last section of the collection view. It doesn’t work in this
//  app because the final rows are in different sections. This is a known
//  issue for which we are investigating a fix in a future release. Yu can
//  work around the issue by using focus guides or refactoring the layout
//  of your collection view."
//
//  To prevent this issue we use this custom FlowLayout that helps the layout
//  by placing FocusGuides into the empty spots. This directs the focus to the
//  correct target. We can switch back to the standard UICollectionViewFLowLayout
//  if Apple fixes the bug in a future release.

#import <UIKit/UIKit.h>

extern NSString * const ARNCollectionElementKindFocusGuide;

@interface ARNCollectionViewFocusGuideFlowLayout : UICollectionViewFlowLayout

@end
