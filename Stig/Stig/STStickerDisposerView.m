//
//  STStickerDisposerView.m
//  Stig
//
//  Created by Lucas Tenório on 17/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STStickerDisposerView.h"



@interface STStickerDisposerViewSpot :NSObject

@property (nonatomic, readonly) NSUInteger spotIndex;
@property (nonatomic, readonly) CGPoint translation;
@property (nonatomic, readonly) CGAffineTransform transform;
- (id) initWithSpotIndex:(NSUInteger) spotIndex andTranslation:(CGPoint) translation;
@end
@implementation STStickerDisposerViewSpot
- (id) initWithSpotIndex:(NSUInteger) spotIndex andTranslation:(CGPoint) translation {
    self = [super init];
    if (self) {
        _spotIndex = spotIndex;
        _translation = translation;
    }
    return self;
}
- (CGAffineTransform) transform {
    return CGAffineTransformMakeTranslation(self.translation.x, self.translation.y);
}
@end



@implementation STStickerDisposerView {
    CGSize _disposedViewSize;
    NSUInteger _numberOfStickers;
    NSUInteger _selectedButonTag;
    NSArray *_spots;
    NSArray *_buttons;

    CGFloat _bounceRadius;
}
#pragma mark - Initialization
- (id) initWithStickerType:(STStickerType)type {
    self = [super init];
    if (self) {
        [self configWithStickerType:type];
    }
    return self;
}
- (void) configWithStickerType:(STStickerType) type{
    _stickerType = type;
    [self loadDefaults];
    [self setupSpots];
    [self setupButtons];
}
- (void) loadDefaults {
    _numberOfStickers = 3;
    _disposedViewSize = CGSizeMake(44.0, 44.0);
    _disposing = NO;
    _animating = NO;
    _selectedButonTag = 0;
    _bounceRadius = 3.0;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = NO;
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}
- (void) setupSpots {
    NSMutableArray *spots = [[NSMutableArray alloc] initWithCapacity:_numberOfStickers];
    for (int i = 0; i < _numberOfStickers; i++) {
        STStickerDisposerViewSpot *spot = [[STStickerDisposerViewSpot alloc] initWithSpotIndex:i andTranslation:CGPointMake(0.0, _disposedViewSize.height*-i)];
        [spots addObject:spot];
    }
    _spots = spots;
}
- (void) setupButtons {
    UIButton *neutral = [self createButtonWithModifier:STSTickerModifierNeutral];
    UIButton *bad = [self createButtonWithModifier:STStickerModifierBad];
    UIButton *good = [self createButtonWithModifier:STSTickerModifierGood];

    neutral.tag = 0;
    bad.tag = 1;
    good.tag = 2;

    bad.alpha = 0.0;
    good.alpha = 0.0;
    neutral.alpha = 0.5;
    

    [self addSubview:good];
    [self addSubview:bad];
    [self addSubview:neutral];

    _buttons = @[neutral,bad,good];
}
- (UIButton *) createButtonWithModifier:(STSTickerModifier) modifier {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0.0, 0.0, _disposedViewSize.width, _disposedViewSize.height);
    STSticker *sticker = [[STSticker alloc] initWithType:self.stickerType andModifier:modifier];
    [button setBackgroundImage:[sticker stickerIconWithPlace:@"selector"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchDown];
    
    return button;
}
- (CGSize) intrinsicContentSize {
    return _disposedViewSize;
}
#pragma mark - User Interaction
- (void) buttonPressed:(UIButton *) button {
    if (!self.disposing) {
        [self disposeButtons];
    } else {
        [self hideButtonsWithSelectedButtonTag:button.tag];
    }
}
- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.disposing) {
        return [super pointInside:point withEvent:event];
    }else {
        for(int i = 0; i < [_buttons count]; i++){
            CGPoint the_point = [_buttons[i] convertPoint:point fromView:self];
            if([_buttons[i] pointInside:the_point withEvent:event]){
                return YES;
            }
        }
        [self hideButtonsWithSelectedButtonTag:_selectedButonTag];
        return NO;
    }
}
#pragma mark - Button Movement
- (void) disposeButtons{
    if (!self.animating) {
        [self willDispose];
        _animating = YES;
        for (UIButton *button in _buttons) {
            STStickerDisposerViewSpot *spot = _spots[button.tag];
            float deltaTiming = (button.tag +0.0)/ 100.0;
            deltaTiming *=2*M_PI;

            CGAffineTransform mainTransform = spot.transform;
            CGAffineTransform bounceTransform = CGAffineTransformMakeTranslation(mainTransform.tx, mainTransform.ty + _bounceRadius);


            [UIView animateWithDuration:0.1+deltaTiming animations:^{
                if (button.tag != 0) {
                    button.alpha = 1.0;
                }else{
                    button.alpha = 0.5;
                }
                button.transform = mainTransform;
            }completion:^(BOOL completed) {
                [UIView animateWithDuration:0.05 animations:^{
                    button.transform = bounceTransform;
                } completion:^(BOOL completed) {
                    [UIView animateWithDuration:0.05 animations:^{
                        button.transform = mainTransform;
                    } completion:^(BOOL completed)  {
                        if ([button isEqual:[_buttons lastObject]]) {
                            _animating = NO;
                            [self didDispose];
                        }
                    }];
                }];
            }];
        }
        _disposing = YES;
    }
}
- (void) hideButtonsWithSelectedButtonTag:(NSUInteger) tag {
    if (!self.animating) {
        [self willHide];
        _animating = YES;
        for (UIButton *button in _buttons) {
            float deltaTiming = (button.tag +0.0)/ 100.0;
            deltaTiming *=2*M_PI;
            [UIView animateWithDuration:0.1+deltaTiming animations:^{
                button.transform = CGAffineTransformIdentity;
                if (button.tag != tag) {
                    button.alpha = 0.0;
                }
            } completion:^(BOOL completed){
                if ([button isEqual:[_buttons lastObject]]) {
                    _animating = NO;
                    [self didHide];
                    [self selectedSticker:[[STSticker alloc] initWithType:self.stickerType andModifier:[self stickerForTag:tag]]];
                }
            }];
        }
        _selectedButonTag = tag;
        _disposing = NO;
    }
    
}

- (STSTickerModifier) stickerForTag:(NSUInteger) tag {
    if (tag == 0) {
        return STSTickerModifierNeutral;
    }else if(tag == 1) {
        return STStickerModifierBad;
    }
    return STSTickerModifierGood;
}
#pragma mark - Delegate callbacks
- (void) willDispose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerDisposerViewWillDispose:)]) {
        [self.delegate stickerDisposerViewWillDispose:self];
    }
}
- (void) didDispose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerDisposerViewDidDispose:)]) {
        [self.delegate stickerDisposerViewDidDispose:self];
    }
}
- (void) willHide {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerDisposerViewWillHide:)]) {
        [self.delegate stickerDisposerViewWillHide:self];
    }
}
- (void) didHide {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerDisposerViewDidHide:)]) {
        [self.delegate stickerDisposerViewDidHide:self];
    }
}
- (void) selectedSticker:(STSticker *) sticker {
    _selectedSticker = sticker;
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerDisposerView:selectedSticker:)]) {
        [self.delegate stickerDisposerView:self selectedSticker:sticker];
    }
}
@end


