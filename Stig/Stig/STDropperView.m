//
//  STDropperView.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 27/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STDropperView.h"

@implementation STDropperView

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
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]
                                             initWithTarget:self action:@selector(respondToPanGesture:)];
        
    [self addGestureRecognizer:panRecognizer];
    
    _state = STDropperViewStateHidden;
}

#define ZOID_ZERO -535

-(void) hide: (void (^)(BOOL completed)) completion{
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.20 animations:^{
        self.viewConstraint.constant = ZOID_ZERO;
        [self.superview layoutIfNeeded];
    }];
    if(completion) completion(YES);
}

-(void) showBasicInformation: (void (^)(BOOL completed)) completion{
    BOOL down = YES;
    if(_state == STDropperViewStateDragging || _state == STDropperViewStateFullInformation){
        down = NO;
    }
    _state = STDropperViewStateAnimating;
    if(down){
        self.viewConstraint.constant = ZOID_ZERO + 105;
    } else{
        self.viewConstraint.constant = ZOID_ZERO + 95;
    }
    [UIView animateWithDuration:0.30 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        [self.superview layoutIfNeeded];
    }completion:^(BOOL completed){
        self.viewConstraint.constant = ZOID_ZERO + 100;
        [UIView animateWithDuration:0.15 animations:^{
            [self.superview layoutIfNeeded];
        }completion:^(BOOL completed){
            _state = STDropperViewStateBasicInformation;
            self.userInteractionEnabled = YES;
            if(completion) completion(YES);
        }];
    }];
}



- (void)respondToPanGesture:(UIPanGestureRecognizer *)recognizer{
    
    CGPoint translation = [recognizer translationInView:self];
    
    if([recognizer state] == UIGestureRecognizerStateBegan){
        if(self.delegate){
            [self.delegate dragStarted];
        }
        _state = STDropperViewStateDragging;
    }
    
    if(_state == STDropperViewStateDragging){
        if(translation.y < 0) return;
        
        self.viewConstraint.constant = ZOID_ZERO + 100 + translation.y;
        [self.superview layoutIfNeeded];
        
        if(translation.y >= 328){
            _state = STDropperViewStateAnimating;
                
            [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.viewConstraint.constant = ZOID_ZERO + 95;
                self.userInteractionEnabled = NO;
                [self.superview layoutIfNeeded];
            }completion:^(BOOL completed){
                self.viewConstraint.constant = ZOID_ZERO + 100;
                [UIView animateWithDuration:0.10 animations:^{
                    [self.superview layoutIfNeeded];
                }completion:^(BOOL completed){

                    self.userInteractionEnabled = YES;
                    _state = STDropperViewStateBasicInformation;
                    if(self.delegate){
                        [self.delegate dragCompleted];
                    }
                }];
            }];

        } else if (([recognizer state] == UIGestureRecognizerStateEnded) || ([recognizer state] == UIGestureRecognizerStateCancelled)) {
            
            _state = STDropperViewStateAnimating;
            
            self.viewConstraint.constant = ZOID_ZERO + 95;
            self.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                [self.superview layoutIfNeeded];
            }completion:^(BOOL completed){
                self.viewConstraint.constant = ZOID_ZERO + 100;
                [UIView animateWithDuration:0.10 animations:^{
                    [self.superview layoutIfNeeded];
                }completion:^(BOOL completed){
                    self.userInteractionEnabled = YES;
                    _state = STDropperViewStateBasicInformation;
                    if(self.delegate){
                        [self.delegate dragCancelled];
                    }
                }];
            }];
        }
    }
}


@end
