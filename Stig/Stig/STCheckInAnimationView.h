//
//  STCheckInAnimationView.h
//  Stig
//
//  Created by Lucas Tenório on 02/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STCheckInAnimationView : UIView
@property (nonatomic, readonly) CGSize initialSize;
@property (nonatomic, readonly) CGSize finalSize;
@property (nonatomic, strong) UIColor *ellipseColor;
@property (nonatomic) CGFloat percentage;
@end
