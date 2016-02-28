//
//  ARNFocusTextView.h
//  classicFilms
//
//  Created by Stefan Arn on 19/02/16.
//  Copyright © 2016 Stefan Arn. All rights reserved.
//
// Based on https://gist.github.com/Cedrick84/8922a0af730c39c05794

#import <UIKit/UIKit.h>

@protocol ARNFocusTextViewDelegate<NSObject>
- (void)focusTextViewClicked;
@end

@interface ARNFocusTextView : UITextView

@property (nonatomic, weak) id<ARNFocusTextViewDelegate> focusTextViewDelegate;
- (void)isTouchable:(BOOL)touchable;

@end
