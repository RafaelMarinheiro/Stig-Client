//
//  UIColor+Stig.h
//  Stig
//
//  Created by Lucas Tenório on 06/09/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Stig)
+ (UIColor *) stigYellow;
+ (UIColor *) stigGrey;
+ (UIColor *) stigWhite;
+ (UIColor *) stigGreen;
+ (UIColor *) stigRed;
+ (UIColor *) colorInterpolatingColor:(UIColor *) initialColor toColor:(UIColor *) finalColor withPercentage:(CGFloat) percentage;
@end
