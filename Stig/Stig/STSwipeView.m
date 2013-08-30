//
//  STSwipeView.m
//  Stig
//
//  Created by Lucas Tenório on 28/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STSwipeView.h"
#import "YIInnerShadowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation STSwipeView {
    NSLayoutConstraint *_swipeConstraint;
}
#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _config];
    }
    return self;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _config];
    }
    return self;
}
- (void) _setupViews {
    _leftSwipeView = [[UIView alloc] initWithFrame:self.bounds];
    [_leftSwipeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_leftSwipeView];

    _rightSwipeView = [[UIView alloc] initWithFrame:self.bounds];
    [_rightSwipeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_rightSwipeView];

    _mainSwipeView = [[UIView alloc] initWithFrame:self.bounds];
    [_mainSwipeView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_mainSwipeView];
}
- (void) _setupConstraints {
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_mainSwipeView(self)]"
                                                                   options:0
                                                                   metrics:nil
                                                                     views:NSDictionaryOfVariableBindings(_mainSwipeView,self)];
    _swipeConstraint = constraints[0];
    [self addConstraints:constraints];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_leftSwipeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftSwipeView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_rightSwipeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_rightSwipeView)]];

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_mainSwipeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_mainSwipeView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_leftSwipeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_leftSwipeView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_rightSwipeView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_rightSwipeView)]];
}
- (void) _setupDefaults {
    UIColor *sameGray = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    _mainSwipeView.backgroundColor = [UIColor whiteColor];
    _leftSwipeView.backgroundColor = sameGray;
    _rightSwipeView.backgroundColor = sameGray;

//    [_mainSwipeView.layer setShadowRadius:20.0];
//    [_mainSwipeView.layer setShadowOpacity:1.0];
//    [_mainSwipeView.layer setShadowOffset:CGSizeMake(0.0, 0.0)];
//    _mainSwipeView.clipsToBounds = NO;
}
- (void) _setupLeftView {
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];

    [label setText:@"Like"];
    [label setFont:[UIFont fontWithName:@"Futura" size:20.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor yellowColor]];

    [_leftSwipeView addSubview:label];
    [_leftSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(label)]];
    [_leftSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(label)]];




//    YIInnerShadowView *shadow = [[YIInnerShadowView alloc] init];
//    [shadow setTranslatesAutoresizingMaskIntoConstraints:NO];
//    shadow.shadowMask = YIInnerShadowMaskVertical;
//    shadow.shadowOffset = CGSizeMake(0.0f, 0.0f);
//    shadow.shadowColor = [UIColor blackColor];
//    shadow.shadowOpacity = 1.0;
//    shadow.shadowRadius = 10.0;
//    [_leftSwipeView addSubview:shadow];
//    [_leftSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[shadow]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(shadow)]];
//    [_leftSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[shadow]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(shadow)]];
}
- (void) _setupRightView {
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];

    [label setText:@"Like"];
    [label setFont:[UIFont fontWithName:@"Futura" size:20.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor yellowColor]];

    [_rightSwipeView addSubview:label];
    [_rightSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[label]-|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(label)]];
    [_rightSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(label)]];
}

- (void) _config {
    [self _setupViews];
    [self _setupConstraints];
    [self _setupDefaults];
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [_mainSwipeView addGestureRecognizer:pan];
//    [pan setDelegate:self];
    [self _setupLeftView];
    [self _setupRightView];
}
- (CGSize) intrinsicContentSize {
    return [_mainSwipeView intrinsicContentSize];
}

- (void) handlePan:(UIPanGestureRecognizer *) pan {
    
    CGPoint translation = [pan translationInView:self];
    pan.cancelsTouchesInView = NO;

    if (translation.x >0) {
        [self sendSubviewToBack:_rightSwipeView];
    }else {
        [self sendSubviewToBack:_leftSwipeView];
    }
    _swipeConstraint.constant = translation.x;

    
    

    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        [self animateToNormal];
    }
}
- (void) animateToNormal {
    _swipeConstraint.constant = 0.0;
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
        UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
        CGPoint point = [g velocityInView:self];
        if (fabsf(point.x) > fabsf(point.y) ) {
            return YES;
        }
    }
    return NO;
}
@end
