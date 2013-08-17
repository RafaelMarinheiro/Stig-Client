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
    [self loadDefaults];
    [self setupSpots];
    [self setupButtons];
}
- (void) loadDefaults {
    _numberOfStickers = 3;
    _disposedViewSize = CGSizeMake(44.0, 44.0);
    _disposing = NO;
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

    bad.hidden = YES;
    good.hidden = YES;
    neutral.alpha = 0.7;
    

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
    for (UIButton *button in _buttons) {
        button.hidden = NO;
        STStickerDisposerViewSpot *spot = _spots[button.tag];
        float deltaTiming = (button.tag +0.0)/ 100.0;
        deltaTiming *=2*M_PI;

        CGAffineTransform mainTransform = spot.transform;
        CGAffineTransform bounceTransform = CGAffineTransformMakeTranslation(mainTransform.tx, mainTransform.ty + _bounceRadius);
        

        [UIView animateWithDuration:0.1+deltaTiming animations:^{
            button.transform = mainTransform;
        }completion:^(BOOL completed) {
            [UIView animateWithDuration:0.05 animations:^{
                button.transform = bounceTransform;
            } completion:^(BOOL completed) {
                [UIView animateWithDuration:0.05 animations:^{
                    button.transform = mainTransform;
                }];
            }];
        }];
    }
    _disposing = YES;
}
- (void) hideButtonsWithSelectedButtonTag:(NSUInteger) tag {
    for (UIButton *button in _buttons) {
        float deltaTiming = (button.tag +0.0)/ 100.0;
        deltaTiming *=2*M_PI;
        [UIView animateWithDuration:0.1+deltaTiming animations:^{
            button.transform = CGAffineTransformIdentity;
        } completion:^(BOOL completed){
            if (button.tag != tag) {
                button.hidden = YES;
            }
        }];
    }
    _selectedButonTag = tag;
    _disposing = NO;
}
@end


