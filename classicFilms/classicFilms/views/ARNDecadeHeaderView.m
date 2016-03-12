//
//  ARNDecadeHeaderView.m
//  classicFilms
//
//  Created by Stefan Arn on 06/12/15.
//  Copyright © 2015 Stefan Arn. All rights reserved.
//

#import "ARNDecadeHeaderView.h"

@interface ARNDecadeHeaderView ()
    @property (nonatomic, strong) UILabel *label;
    @property (nonatomic, strong) UIView *line;
@end

@implementation ARNDecadeHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        float padding = 100.0f;
        float labelHeight = 60.0f;
        float lineThickness = 1.0f;
        
        // line
        _line = [[UIView alloc] initWithFrame:CGRectMake(padding, (self.frame.size.height / 2) - (lineThickness / 2) + (labelHeight / 2), self.frame.size.width - (2 * padding), lineThickness)];
        _line.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_line];
        
        // label
        _label = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 0.0f, 0.0f)];
        _label.backgroundColor = [UIColor clearColor];
        _label.font = [UIFont systemFontOfSize:40.0f];
        _label.textColor = [UIColor grayColor];
        [self addSubview:_label];
    }
    return self;
}

- (void)prepareForReuse {
    self.label.text = [NSString string];
}

- (void)configureViewWithTitle:(NSString *)title {
    if ([title length] > 0) {
        self.label.text = title;
        [self.label sizeToFit];
        
        CGRect adjustedFrame = self.label.frame;
        adjustedFrame.origin.x = (self.frame.size.width - self.label.frame.size.width) / 2;
        adjustedFrame.origin.y = self.line.frame.origin.y - self.label.frame.size.height;
        self.label.frame = adjustedFrame;
    }
}

@end
