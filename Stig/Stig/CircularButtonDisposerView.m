//
//  CIrcularButtonDisposerView.m
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "CircularButtonDisposerView.h"

@implementation CircularButtonDisposerView;

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}
- (void) config {
    _disposeToTheRight = YES;
    _disposeToTheBottom = NO;
    _disposing = NO;
    _animating = NO;
    self.disposeRadius = @100.0;
    self.disposeAngle = @(M_PI/2.0);
    self.disposeCenter = CGPointMake(30.0, 30.0);
    self.numberOfButtons = 3;
    self.bounceRadiusDelta = 5.0;
    
    CGRect frame = CGRectMake(0.0, 0.0, 60.0, 60.0);

    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:self.numberOfButtons];

    for (int i =0; i < self.numberOfButtons; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.tag = i;
        button.frame = frame;
        
        [button setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(disposedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [buttons addObject:button];
    }
    self.buttons = buttons;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
 
    button.frame = frame;
    [button setEnabled:YES];
    [button setUserInteractionEnabled:YES];
    [button setImage:[UIImage imageNamed:@"uk-board.jpg"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(mainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    self.userInteractionEnabled = YES;
}
#pragma mark -
#pragma mark User Reaction
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isDisposing) {
        float radius = [self.disposeRadius floatValue];
        
        CGRect disposeRect = CGRectMake(0.0, - radius, self.frame.size.width + radius, self.frame.size.height + radius);
        BOOL result = CGRectContainsPoint(disposeRect, point);
        return result;
    }
    return CGRectContainsPoint(self.bounds, point);
}
- (void) disposedButtonPressed:(UIButton *) button {
    if (self.callback) {
        self.callback(button.tag);
    }
}
- (void) mainButtonPressed:(UIButton *) sender {
    if (![self isDisposing]) {
        
        [sender setUserInteractionEnabled:NO];
        [self dispose:^(BOOL completed){
            [sender setUserInteractionEnabled:YES];
        }];
    } else {
        [sender setUserInteractionEnabled:NO];
        [self hideButtons:^(BOOL completed){
            [sender setUserInteractionEnabled:YES];
        }];
    }
}

#pragma mark -
#pragma mark Transform Calculation
- (CGAffineTransform) transformForPosition:(NSUInteger) position withDisposeRadius: (float) disposeRadius disposeAngle:(float) disposeAngle andAnimationCenter:(CGPoint) center {
    float theta = (disposeAngle / (self.numberOfButtons - 1)) * position;
    float deltaX = cosf(theta) * disposeRadius;
    float deltaY = - sinf(theta) * disposeRadius;

    if (!self.disposeToTheRight) {
        deltaX = -deltaX;
    }
    if (self.disposeToTheBottom){
        deltaY = -deltaY;
    }

    return CGAffineTransformMakeTranslation(deltaX, deltaY);
}
#pragma mark -
#pragma mark State Changes
- (void) dispose:(void (^)(BOOL completed)) completion{
    if (!self.disposing && !self.animating) {
        _animating = YES;
        for (int i = 0 ; i < self.numberOfButtons; i++) {
            UIView *view = self.buttons[i];
            CGAffineTransform translation = [self transformForPosition:i withDisposeRadius:[self.disposeRadius floatValue] disposeAngle:[self.disposeAngle floatValue] andAnimationCenter:self.disposeCenter];
            CGAffineTransform bounceTranslation = [self transformForPosition:i withDisposeRadius:[self.disposeRadius floatValue] - self.bounceRadiusDelta disposeAngle:[self.disposeAngle floatValue] andAnimationCenter:self.disposeCenter];
            float deltaTiming = (i +0.0)*(i +0.0)/ 100.0;
            [UIView animateWithDuration:0.1 + deltaTiming delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                view.transform = translation;
            }completion:^(BOOL completed){
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                    view.transform = bounceTranslation;
                }completion:^(BOOL completed){
                    [UIView animateWithDuration:0.05 animations:^{
                        view.transform = translation;
                    } completion:^(BOOL completed) {
                        _disposing = YES;
                        _animating = NO;
                        completion(completed);
                    }];
                }];
            }];
        }
    }
}
- (void) hideButtons:(void (^)(BOOL completed)) completion{
    if (self.disposing && !self.animating) {
        _animating = YES;
        for (int i = 0 ; i < self.numberOfButtons; i++) {
            UIView *view = self.buttons[i];
            float deltaTiming = (i +0.0)*(i +0.0)/ 100.0;
            [UIView animateWithDuration:0.1+deltaTiming animations:^{
                view.transform = CGAffineTransformRotate(view.transform, M_PI);
            }completion:^(BOOL completed){
                [UIView animateWithDuration:0.1+deltaTiming animations:^{
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL completed){
                    _disposing = NO;
                    _animating = NO;
                    completion(completed);
                }];
            }];
        }
        
    }
    
}
@end
