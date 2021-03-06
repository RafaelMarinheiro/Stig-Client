//
//  STStickerSelectorView.m
//  Stig
//
//  Created by Lucas Tenório on 31/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STStickerPickerView.h"
#import "STLinearLayoutView.h"
#import "STStickerDisposerView.h"
@implementation STStickerPickerView {
    STLinearLayoutView *_layoutView;
    NSMutableDictionary *_buttonsStickers;
}
#pragma mark - Initialization
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configWithModifier:STSTickerModifierNeutral];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configWithModifier:STSTickerModifierNeutral];
    }
    return self;
}
- (id) initWithStickerModifier:(STSTickerModifier) modifier {
    self = [super init];
    if (self) {
        [self configWithModifier:modifier];
    }
    return self;
}
- (void) configWithModifier:(STSTickerModifier) modifier{
    _shouldSelectStickers = YES;
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:6];
    _buttonsStickers = [NSMutableDictionary dictionaryWithCapacity:6];
    for (int i = 0; i < 6; i++) {
        NSNumber *stickerId = @(i*3+modifier);
        STSticker *sticker = [[STSticker alloc] initWithId:stickerId];
        UIButton *stickerButton = [self buttonForSticker:sticker];
        [stickerButton addTarget:self action:@selector(stickerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        stickerButton.tag = i;
        [buttons addObject:stickerButton];
        [_buttonsStickers setObject:sticker forKey:@(i)];
    }
    _layoutView = [[STLinearLayoutView alloc] initWithViews:buttons viewSize:CGSizeMake(44.0, 44.0) viewSeparator:0.0 andEdgeSeparator:0.0];
    [_layoutView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self addSubview:_layoutView];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_layoutView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1
                                                      constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:_layoutView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
    [self invalidateIntrinsicContentSize];
}
- (CGSize) intrinsicContentSize {
    if (_layoutView) {
        return [_layoutView intrinsicContentSize];
    }else{
        return [super intrinsicContentSize];
    }
}
#pragma mark - Managing Buttons
- (UIButton *) buttonForSticker:(STSticker *) sticker {
    UIImage *image = [sticker stickerIconWithPlace:@"selector"];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"sticker-background"] forState:UIControlStateSelected];
    return button;
}
- (UIButton *) buttonWithStickerType:(STStickerType) type {
    return _layoutView.views[type];
}
- (void) setSticker:(STSticker *) sticker forButton:(UIButton *) button {
    _buttonsStickers[@(button.tag)] = sticker;
}
- (STSticker *) stickerForButton:(UIButton *) button {
    return _buttonsStickers[@(button.tag)];
}
- (void) selectStickerWithType:(STStickerType) type {
    UIButton *button = [self buttonWithStickerType:type];
    if (!button.selected) {
        button.selected = YES;
    }
    [self stickerSelected:[self stickerForButton:button]];
}
- (void) deselectStickerWithType:(STStickerType) type {
    UIButton *button = [self buttonWithStickerType:type];
    if (button.selected) {
        button.selected = NO;
    }
    [self stickerDeselected:[self stickerForButton:button]];
}
#pragma mark - Setting Stickers
- (void) setSticker:(STSticker *) sticker {
    UIButton *stickerButton = [self buttonWithStickerType:sticker.type];
    
    [stickerButton setImage:[sticker stickerIconWithPlace:@"selector"] forState:UIControlStateNormal];
    [self setSticker:sticker forButton:stickerButton];
}
- (void) setStickersWithIds:(NSArray *)stickerIds {
    for (NSNumber *stickerId in stickerIds) {
        STSticker *sticker = [[STSticker alloc] initWithId:stickerId];
        [self setSticker:sticker];
    }
}
- (void) setStickers:(NSArray *) stickers {
    for (STSticker *sticker in stickers) {
        [self setSticker:sticker];
    }
}
#pragma mark - User interaction
- (void) stickerButtonPressed:(UIButton *) button {
    STSticker *s = [self stickerForButton:button];
    
    [self stickerPicked:s];

    if (self.shouldSelectStickers) {
        if (button.selected) {
            [self deselectStickerWithType:s.type];
        }else{
            [self selectStickerWithType:s.type];
        }
    }
}
#pragma mark - Change Selection Array
- (void) stickerSelected:(STSticker *) sticker {
    if (!_selectedStickers) {
        _selectedStickers = @[];
    }
    NSMutableArray *selectedStickers = [_selectedStickers mutableCopy];
    [selectedStickers addObject:sticker];
    _selectedStickers = selectedStickers;
    [self stickerSelectionDidChange];
}
- (void) stickerDeselected:(STSticker *) sticker {
    NSMutableArray *selectedStickers = [_selectedStickers mutableCopy];
    [selectedStickers removeObject:sticker];
    _selectedStickers = selectedStickers;
    if ([_selectedStickers count] == 0) {
        _selectedStickers = nil;
    }
    [self stickerSelectionDidChange];
}
#pragma mark - Delegate callbacks
- (void) stickerPicked:(STSticker *) sticker {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerPicker:stickerPicked:)]) {
        [self.delegate stickerPicker:self stickerPicked:sticker];
    }
}
- (void) stickerSelectionDidChange {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerPickerSelectionDidChange:)]) {
        [self.delegate stickerPickerSelectionDidChange:self];
    }
}

@end
