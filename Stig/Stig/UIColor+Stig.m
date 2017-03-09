//
//  UIColor+Stig.m
//  Stig
//
//  Created by Lucas Tenório on 06/09/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "UIColor+Stig.h"

@implementation UIColor (Stig)
+ (UIColor *) stigYellow {
    return [UIColor colorWithRed:250/255.0 green:205/255.0 blue:51/255.0 alpha:1.0];
}
+ (UIColor *) stigGrey {
    return [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
}
+ (UIColor *) stigWhite {
    return [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
}
+ (UIColor *) stigGreen {
    return [UIColor colorWithRed:85/255.0 green:176/255.0 blue:145/255.0 alpha:1.0];
}
+ (UIColor *) stigRed {
    return [UIColor colorWithRed:236/255.0 green:110/255.0 blue:111/255.0 alpha:1.0];
}
+ (UIColor *) colorInterpolatingColor:(UIColor *) initialColor toColor:(UIColor *) finalColor withPercentage:(CGFloat) percentage {

    if (percentage <0.0) {
        percentage = 0.0;
    }
    if (percentage > 1.0) {
        percentage = 1.0;
    }
    CGFloat initialRed, initialGreen, initialBlue, initialAlpha;
    [initialColor getRed:&initialRed green:&initialGreen blue:&initialBlue alpha:&initialAlpha];
    CGFloat finalRed, finalGreen, finalBlue, finalAlpha;
    [finalColor getRed:&finalRed green:&finalGreen blue:&finalBlue alpha:&finalAlpha];

    CGFloat redDelta = (finalRed - initialRed) * percentage;
    CGFloat greenDelta = (finalGreen - initialGreen) * percentage;
    CGFloat blueDelta = (finalBlue - initialBlue) * percentage;
    CGFloat alphaDelta = (finalAlpha - initialAlpha) * percentage;

    return [UIColor colorWithRed:initialRed+redDelta green:initialGreen+greenDelta blue:initialBlue + blueDelta alpha:initialAlpha+alphaDelta];
}

@end
