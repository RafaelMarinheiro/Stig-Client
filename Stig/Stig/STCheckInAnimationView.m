//
//  STCheckInAnimationView.m
//  Stig
//
//  Created by Lucas Tenório on 02/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STCheckInAnimationView.h"

@implementation STCheckInAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}

- (void) config {
    
     
    _finalSize = CGSizeMake(320.0, 2.0);
    _initialSize = CGSizeMake(30.0, 30.0);
    _ellipseColor = [UIColor colorWithRed:249.0/255.0 green:204.0/255.0 blue:51.0/255.0 alpha:1.0];
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = NO;
    

    [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}
- (CGSize) intrinsicContentSize {
    return CGSizeMake(MAX(self.initialSize.width, self.finalSize.width), MAX(self.initialSize.height, self.finalSize.height));

}
- (void) setPercentage:(CGFloat)percentage {
    _percentage = percentage;
    [self setNeedsDisplay];
}
- (void) setEllipseColor:(UIColor *)ellipseColor {
    _ellipseColor = ellipseColor;
    [self setNeedsDisplay];
}
- (CGRect) centeredRectWithSize:(CGSize) size {
    CGFloat x = (self.frame.size.width - size.width) / 2.0;
    CGFloat y = (self.frame.size.height - size.height) / 2.0;
    return CGRectMake(x, y, size.width, size.height);
}
- (CGRect) rectFromInitialSize:(CGSize) initialSize finalSize:(CGSize) finalSize andPercentage:(CGFloat) percentage{

    if (percentage > 1.0) {
        percentage = 1.0;
    }else if (percentage<0.0){
        percentage = 0.0;
    }

    CGFloat finalWidth  = finalSize.width;

    double wt = (1-percentage)*(initialSize.width/2) + percentage*(finalWidth/2);
    double ht = (initialSize.height/2)*(initialSize.width/2)/wt;


    CGFloat widthDelta = (finalSize.width - initialSize.width) * percentage;
    CGFloat heightDelta = (finalSize.height - initialSize.height) * percentage;

    return [self centeredRectWithSize:CGSizeMake(2*wt, 2*ht)];
}
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.ellipseColor setStroke];
    [self.ellipseColor setFill];
    CGContextSetLineWidth(context, 1.0);
    CGRect ellipseRect = [self rectFromInitialSize:self.initialSize finalSize:self.finalSize andPercentage:self.percentage];
    CGContextAddEllipseInRect(context,ellipseRect );
    CGContextFillEllipseInRect(context, ellipseRect);
    CGContextStrokePath(context);
}


@end
