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
#import "UIColor+Stig.h"


static CGFloat _swipeThreshold = 0.0;
static CGFloat _swipeLenght = 100.0;

@implementation STSwipeView {
    NSLayoutConstraint *_swipeConstraint;
    UIColor *_initialLeftColor;
    UIColor *_finalLeftColor;
    UIColor *_initialRightColor;
    UIColor *_finalRightColor;
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

    _leftIndicatorView = [UIView new];
    [_leftIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainSwipeView addSubview:_leftIndicatorView];
    
    _rightIndicatorView = [UIView new];
    [_rightIndicatorView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [_mainSwipeView addSubview:_rightIndicatorView];
    
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

    [_mainSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_leftIndicatorView(8.0)]"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(_leftIndicatorView)]];

    [_mainSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_leftIndicatorView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(_leftIndicatorView)]];
    [_mainSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[_rightIndicatorView(8.0)]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(_rightIndicatorView)]];

    [_mainSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_rightIndicatorView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(_rightIndicatorView)]];
}
- (void) _setupDefaults {
    _initialLeftColor = [UIColor stigGrey];
    _finalLeftColor = [UIColor stigGreen];

    _initialRightColor = [UIColor stigGrey];
    _finalRightColor = [UIColor stigRed];



    _mainSwipeView.backgroundColor = [UIColor whiteColor];
    _leftSwipeView.backgroundColor = _initialLeftColor;
    _rightSwipeView.backgroundColor = _initialRightColor;

    _leftIndicatorView.backgroundColor = _finalLeftColor;
    _leftIndicatorView.alpha = 0.0;
    _rightIndicatorView.backgroundColor = _finalRightColor;
    _rightIndicatorView.alpha = 0.0;
    _swipeEnabled = NO;
}
- (void) _setupLeftView {
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];

    [label setText:@"Like"];
    [label setFont:[UIFont fontWithName:@"Futura" size:20.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor stigWhite]];

    [_leftSwipeView addSubview:label];
    [_leftSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(label)]];
    [_leftSwipeView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[label]|"
                                                                           options:NSLayoutFormatAlignAllCenterY
                                                                           metrics:nil
                                                                             views:NSDictionaryOfVariableBindings(label)]];
}
- (void) _setupRightView {
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];

    [label setText:@"Dislike"];
    [label setFont:[UIFont fontWithName:@"Futura" size:20.0]];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor stigWhite]];

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
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [_mainSwipeView addGestureRecognizer:pan];
    [pan setDelegate:self];
    [self _setupLeftView];
    [self _setupRightView];
}
- (CGSize) intrinsicContentSize {
    return [_mainSwipeView intrinsicContentSize];
}
- (void) animateViewsForTranslation:(CGFloat) translation {
    BOOL isLeft = YES;
    if (translation < 0) {
        isLeft = NO;
    }
    

    translation = abs(translation);
    if (translation > _swipeThreshold) {
        translation -= _swipeThreshold;
        CGFloat percentage = translation/_swipeLenght;
        if (isLeft) {
            //self.leftSwipeView.backgroundColor = [UIColor colorInterpolatingColor:_initialLeftColor toColor:_finalLeftColor withPercentage:percentage];
            if (self.selectionStatus == STSwipeViewSelectionStatusLeft) {
                if (percentage >= 1.0) {
                    self.leftSwipeView.backgroundColor = _initialLeftColor;
                }else {
                    self.leftSwipeView.backgroundColor = _finalLeftColor;
                }
            }else {
                if (percentage >= 1.0) {
                    self.leftSwipeView.backgroundColor = _finalLeftColor;
                }else {
                    self.leftSwipeView.backgroundColor = _initialLeftColor;
                }
            }
        }else {
            //self.rightSwipeView.backgroundColor = [UIColor colorInterpolatingColor:_initialRightColor toColor:_finalRightColor withPercentage:percentage];
            if (self.selectionStatus == STSwipeViewSelectionStatusRight) {
                if (percentage >= 1.0) {
                    self.rightSwipeView.backgroundColor = _initialRightColor;
                }else {
                    self.rightSwipeView.backgroundColor = _finalRightColor;
                }
            } else {
                if (percentage >= 1.0) {
                    self.rightSwipeView.backgroundColor = _finalRightColor;
                }else {
                    self.rightSwipeView.backgroundColor = _initialRightColor;
                }
            }
            
        }
        
    }

}
- (void) handlePan:(UIPanGestureRecognizer *) pan {
    
    CGPoint translation = [pan translationInView:self];
    pan.cancelsTouchesInView = NO;

    if (translation.x >0) {
        [self sendSubviewToBack:_rightSwipeView];
    }else {
        [self sendSubviewToBack:_leftSwipeView];
    }
    [self animateViewsForTranslation:translation.x];
    _swipeConstraint.constant = translation.x;

    
    if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled || pan.state == UIGestureRecognizerStateFailed) {
        [self animateToNormal];
        if (abs(translation.x) > _swipeThreshold  + _swipeLenght) {
            if (translation.x>0) {
                [self swipedRight];
            }else {
                [self swipedLeft];
            }
        }
    }
}
- (void) animateToNormal {
    _swipeConstraint.constant = 0.0;
    [UIView animateWithDuration:0.15 animations:^{
        [self layoutIfNeeded];
    }];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([self shouldSwipe]) {
        if ([gestureRecognizer class] == [UIPanGestureRecognizer class]) {
            UIPanGestureRecognizer *g = (UIPanGestureRecognizer *)gestureRecognizer;
            CGPoint point = [g velocityInView:self];
            if (fabsf(point.x) > fabsf(point.y) ) {
                return YES;
            }
        }
    }
    return NO;
}
- (void) prepareForReuse {
    self.swipeEnabled = NO;
    self.selectionStatus = STSwipeViewSelectionStatusNone;
}
- (void) setSelectionStatus:(STSwipeViewSelectionStatus)selectionStatus {
    if (selectionStatus == STSwipeViewSelectionStatusNone) {
        self.rightIndicatorView.alpha = 0.0;
        self.leftIndicatorView.alpha = 0.0;
        self.rightSwipeView.backgroundColor = _initialRightColor;
        self.leftSwipeView.backgroundColor = _initialLeftColor;
    } else if (selectionStatus == STSwipeViewSelectionStatusLeft) {
        self.rightIndicatorView.alpha = 0.0;
        self.leftIndicatorView.alpha = 1.0;
        self.rightSwipeView.backgroundColor = _initialRightColor;
        self.leftSwipeView.backgroundColor = _finalLeftColor;
    } else if (selectionStatus == STSwipeViewSelectionStatusRight) {
        self.rightIndicatorView.alpha = 1.0;
        self.leftIndicatorView.alpha = 0.0;
        self.rightSwipeView.backgroundColor = _finalRightColor;
        self.leftSwipeView.backgroundColor = _initialLeftColor;
    }
    _selectionStatus = selectionStatus;
}
- (BOOL) shouldSwipe {
    if (![self swipeEnabled]) {
        return NO;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(swipeViewShouldSwipe:)]) {
        return [self.delegate swipeViewShouldSwipe:self];
    }
    return YES;
}
- (void) swipedLeft {
    if (self.selectionStatus == STSwipeViewSelectionStatusRight) {
        self.selectionStatus = STSwipeViewSelectionStatusNone;
    }else{
        self.selectionStatus = STSwipeViewSelectionStatusRight;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(swipeViewDidSwipeLeft:)]) {
        [self.delegate swipeViewDidSwipeLeft:self];
    }
}
- (void) swipedRight {
    if (self.selectionStatus == STSwipeViewSelectionStatusLeft) {
        self.selectionStatus = STSwipeViewSelectionStatusNone;
    }else{
        self.selectionStatus = STSwipeViewSelectionStatusLeft;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(swipeViewDidSwipeRight:)]) {
        [self.delegate swipeViewDidSwipeRight:self];
    }
}
@end
