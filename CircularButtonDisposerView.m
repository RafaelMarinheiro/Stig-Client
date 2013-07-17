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
    _disposing = NO;
    self.disposeRadius = @200.0;
    self.disposeAngle = @(M_PI/2.0);
    CGRect frame = CGRectMake(0.0, 0.0, 60.0, 60.0);

    UIView *view1 = [[UIView alloc] initWithFrame:frame];
    UIView *view2 = [[UIView alloc] initWithFrame:frame];
    UIView *view3 = [[UIView alloc] initWithFrame:frame];
    UIView *view4 = [[UIView alloc] initWithFrame:frame];
    UIView *view5 = [[UIView alloc] initWithFrame:frame];
    view1.backgroundColor = [UIColor grayColor];
    view2.backgroundColor = [UIColor blueColor];
    view3.backgroundColor = [UIColor greenColor];
    view4.backgroundColor = [UIColor redColor];
    view5.backgroundColor = [UIColor yellowColor];

    
    [self addSubview:view1];
    [self addSubview:view2];
    [self addSubview:view3];
    [self addSubview:view4];
    [self addSubview:view5];
    

    self.viewsToDispose = @[view1,view2,view3,view4,view5];
    

    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
 
    button.frame = frame;
    [button setEnabled:YES];
    [button setUserInteractionEnabled:YES];
    [button setImage:[UIImage imageNamed:@"uk-board.jpg"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(mainButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    //self.clipsToBounds = NO;
    self.userInteractionEnabled = YES;
    NSLog(@"First self%@",self);
}
- (void) layoutSubviews {
    
}
#pragma mark -
#pragma mark User Reaction

- (void) mainButtonPressed:(UIButton *) sender {
    if (![self isDisposing]) {
        for (int i = 0 ; i < [self.viewsToDispose count]; i++) {
            UIView *view = self.viewsToDispose[i];
            

            CGPoint center = CGPointMake(30.0, 30.0);
            CGAffineTransform translation = [self transformForPosition:i withDisposeRadius:[self.disposeRadius floatValue] disposeAngle:[self.disposeAngle floatValue] andAnimationCenter:center];
            CGAffineTransform bounceTranslation = [self transformForPosition:i withDisposeRadius:[self.disposeRadius floatValue] - 5.0 disposeAngle:[self.disposeAngle floatValue] andAnimationCenter:center];
            
            CGAffineTransform firstTranslationWithRotation = CGAffineTransformRotate(translation,  2*M_PI);

            CGAffineTransform secondTranslationWithRotation = CGAffineTransformRotate(bounceTranslation, 2*M_PI);
            
            float deltaTiming = (i +0.0)*(i +0.0)/ 100.0;
            [UIView animateWithDuration:0.1 + deltaTiming delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                view.transform = firstTranslationWithRotation;
            }completion:^(BOOL completed){
                if (completed) {

                    [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
                        view.transform = secondTranslationWithRotation;
                    }completion:^(BOOL completed){
                        [UIView animateWithDuration:0.05 animations:^{
                            
                            view.transform = firstTranslationWithRotation;
                        }];
                    }];
                }
            }];
        }
        _disposing = YES;
    } else {
        
        for (int i = 0 ; i < [self.viewsToDispose count]; i++) {
            UIView *view = self.viewsToDispose[i];
            float deltaTiming = (i +0.0)*(i +0.0)/ 100.0;
            [UIView animateWithDuration:0.1+deltaTiming animations:^{
                view.transform = CGAffineTransformRotate(view.transform, M_PI);
            }completion:^(BOOL completed){
                [UIView animateWithDuration:0.1+deltaTiming animations:^{
                    view.transform = CGAffineTransformIdentity;
                }];
            }];
        }
        _disposing = NO;
    }
}
#pragma mark -
#pragma mark View Positioning
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (CGAffineTransform) transformForPosition:(NSUInteger) position withDisposeRadius: (float) disposeRadius disposeAngle:(float) disposeAngle andAnimationCenter:(CGPoint) center {
    float theta = (disposeAngle / (self.numberOfViewsToDispose - 1)) * position;
    float deltaX = cosf(theta) * disposeRadius;
    float deltaY = - sinf(theta) * disposeRadius;

    return CGAffineTransformMakeTranslation(deltaX, deltaY);
}
- (CGPoint) centerForPosition:(NSUInteger) position withDisposeRadius:(float) disposeRadius andDisposeAngle:(float) disposeAngle {
    float theta = (disposeAngle / (self.numberOfViewsToDispose - 1)) * position;
    float deltaX = cosf(theta) * disposeRadius;
    float deltaY = - sinf(theta) * disposeRadius;
    return CGPointMake(30.0 + deltaX, 30.0 + deltaY);
}

- (CGPoint) centerForPosition:(NSUInteger) position {
    return [self centerForPosition:position withDisposeRadius:[[self disposeRadius] floatValue] andDisposeAngle:[[self disposeAngle]floatValue]];
}

-(NSUInteger) numberOfViewsToDispose {
    return [[self viewsToDispose] count];
}
@end
