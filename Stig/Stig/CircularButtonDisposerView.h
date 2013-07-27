//
//  CircularButtonDisposerView.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^STButtonCallBack)(NSUInteger buttonPressed);
@interface CircularButtonDisposerView : UIView



@property (nonatomic, strong) NSNumber *disposeRadius; 
@property (nonatomic, strong) NSNumber *disposeAngle;
@property (nonatomic) CGPoint disposeCenter;
@property (nonatomic) float bounceRadiusDelta;
@property (nonatomic) NSUInteger numberOfButtons;
@property (nonatomic, strong) UIButton *mainButton;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, readonly, getter = isDisposing) BOOL disposing;
@property (nonatomic, readonly, getter = isAnimating) BOOL animating;
@property (nonatomic, strong) STButtonCallBack callback;

@end
