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
    _shouldRotateMainButton = NO;
    _disposeToTheRight = YES;
    _disposeToTheBottom = NO;
    _disposing = NO;
    _animating = NO;
    _collapsesAfterButtonPress = YES;
    self.disposeRadius = @70.0;
    self.disposeAngle = @(M_PI/2.0);
    self.disposeCenter = CGPointMake(30.0, 30.0);
    self.numberOfButtons = 3;
    self.bounceRadiusDelta = 3.0;
    
    CGRect frame = CGRectMake(0.0, 0.0, 44.0, 44.0);

    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:self.numberOfButtons];

    for (int i =0; i < self.numberOfButtons; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = frame;
        
        //[button setTitle:[NSString stringWithFormat:@"%d",i] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(disposedButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [buttons addObject:button];
        button.hidden = YES;
    }
    self.buttons = buttons;

    self.mainButton = [UIButton buttonWithType:UIButtonTypeCustom];
 
    self.mainButton.frame = frame;
    [self.mainButton setEnabled:YES];
    [self.mainButton setUserInteractionEnabled:YES];
    [self.mainButton addTarget:self action:@selector(mainButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:self.mainButton];
    self.userInteractionEnabled = YES;
}
#pragma mark -
#pragma mark User Reaction
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.isDisposing) {
        for(int i = 0; i < self.numberOfButtons; i++){
            CGPoint the_point = [[self.buttons objectAtIndex:i] convertPoint:point fromView:self];
            if([[self.buttons objectAtIndex:i] pointInside:the_point withEvent:event]){
                return YES;
            }
        }
        CGPoint the_point = [self.mainButton convertPoint:point fromView:self];
        BOOL inside =  [self.mainButton pointInside:the_point withEvent:event];
        if (!inside) {
            if (self.disposing) {
                [self toggleDispose];
            }
        }
        return inside;
    }
    return CGRectContainsPoint(self.bounds, point);
}
- (void) disposedButtonPressed:(UIButton *) button {
    [self circularButtonPressed:button.tag];
    if (self.collapsesAfterButtonPress) {
        [self toggleDispose];
    }
}

-(void) toggleDispose{
    if (![self isDisposing]) {
        
        [self.mainButton setUserInteractionEnabled:NO];
        [self dispose:^(BOOL completed){
            [self.mainButton setUserInteractionEnabled:YES];
        }];
    } else {
        [self.mainButton setUserInteractionEnabled:NO];
        [self hideButtons:^(BOOL completed){
            [self.mainButton setUserInteractionEnabled:YES];
        }];
    }
}

- (void) mainButtonPressed:(UIButton *) sender {
    [self toggleDispose];
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
        [self.superview bringSubviewToFront:self];
        _animating = YES;
        [self circularButtonWillDispose];
        if (self.shouldRotateMainButton) {
            CGAffineTransform mainTransform = CGAffineTransformMakeRotation(M_PI/ 4.1);

            [UIView animateWithDuration:0.20 animations:^{
                self.mainButton.transform = mainTransform;
            }];
        }
        for (int i = 0 ; i < self.numberOfButtons; i++) {
            UIView *view = self.buttons[i];
            view.hidden = NO;
            CGAffineTransform translation = [self transformForPosition:i withDisposeRadius:[self.disposeRadius floatValue] disposeAngle:[self.disposeAngle floatValue] andAnimationCenter:self.disposeCenter];
            CGAffineTransform bounceTranslation = [self transformForPosition:i withDisposeRadius:[self.disposeRadius floatValue] - self.bounceRadiusDelta disposeAngle:[self.disposeAngle floatValue] andAnimationCenter:self.disposeCenter];
            float deltaTiming = (i +0.0)/ 100.0;
            deltaTiming *=2*M_PI;
            [UIView animateWithDuration:0.1 + deltaTiming delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.transform = translation;
            }completion:^(BOOL completed){
                [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    view.transform = bounceTranslation;
                }completion:^(BOOL completed){
                    [UIView animateWithDuration:0.05 animations:^{
                        view.transform = translation;
                    } completion:^(BOOL completed) {
                        if (i == self.numberOfButtons -1) {
                            _disposing = YES;
                            _animating = NO;
                            completion(completed);
                            [self circularButtonDidDispose];
                        }
                    }];
                }];
            }];
        }
    }
}
- (void) hideButtons:(void (^)(BOOL completed)) completion{
    if (self.disposing && !self.animating) {
        _animating = YES;
        [self circularButtonWillHide];
        if (self.shouldRotateMainButton) {
            [UIView animateWithDuration:0.2 animations:^{
                self.mainButton.transform = CGAffineTransformIdentity;
            }];
        }
        for (int i = 0 ; i < self.numberOfButtons; i++) {
            UIView *view = self.buttons[i];
            float deltaTiming = (i +0.0)/ 100.0;
            deltaTiming *=2*M_PI;
            [UIView animateWithDuration:0.1+deltaTiming animations:^{
                view.transform = CGAffineTransformRotate(view.transform, M_PI);
            }completion:^(BOOL completed){
                [UIView animateWithDuration:0.1 animations:^{
                    view.transform = CGAffineTransformIdentity;
                } completion:^(BOOL completed){
                    view.hidden = YES;
                    if (i == self.numberOfButtons - 1) {
                        _disposing = NO;
                        _animating = NO;
                        completion(completed);
                        [self circularButtonDidHide];
                    }
                }];
            }];
        }
    }
}

#pragma mark - Delegate Callbacks
- (void) circularButtonWillDispose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularButtonDisposerViewWillDispose:)]) {
        [self.delegate circularButtonDisposerViewWillDispose:self];
    }
}
- (void) circularButtonDidDispose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularButtonDisposerViewDidDispose:)]) {
        [self.delegate circularButtonDisposerViewDidDispose:self];
    }
}
- (void) circularButtonWillHide {
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularButtonDisposerViewWillHide:)]) {
        [self.delegate circularButtonDisposerViewWillHide:self];
    }
}
- (void) circularButtonDidHide {
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularButtonDisposerViewDidHide:)]) {
        [self.delegate circularButtonDisposerViewDidHide:self];
    }
}
- (void) circularButtonPressed:(NSUInteger) buttonTag{
    if (self.delegate && [self.delegate respondsToSelector:@selector(circularButtonDisposerView:buttonPressed:)]) {
        [self.delegate circularButtonDisposerView:self buttonPressed:buttonTag];
    }
}
@end
