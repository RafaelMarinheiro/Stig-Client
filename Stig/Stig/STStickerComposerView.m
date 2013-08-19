//
//  STStickerComposerView.m
//  Stig
//
//  Created by Lucas Tenório on 13/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STStickerComposerView.h"
#import "STLinearLayoutView.h"

@implementation STStickerComposerView {
    STLinearLayoutView *_linearLayoutView;
    NSArray *_disposers;
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
    self.backgroundColor = [UIColor clearColor];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
    NSMutableArray *stickers = [NSMutableArray arrayWithCapacity:6];
    for (int i = 0; i < 6; i++) {
        STStickerDisposerView *sticker = [[STStickerDisposerView alloc] initWithStickerType:i];
        sticker.delegate = self;
        [stickers addObject:sticker];
    }
    _disposers = stickers;
    _linearLayoutView = [[STLinearLayoutView alloc] initWithViews:stickers viewSize:CGSizeMake(44.0, 44.0) viewSeparator:0.0 andEdgeSeparator:0.0];
    
    [_linearLayoutView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:_linearLayoutView];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_linearLayoutView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_linearLayoutView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_linearLayoutView]-0-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:NSDictionaryOfVariableBindings(_linearLayoutView)]];
}
- (CGSize) intrinsicContentSize {
    if (_linearLayoutView) {
        return [_linearLayoutView intrinsicContentSize];
    }
    return CGSizeZero;
}

- (BOOL) pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL normalResult = [super pointInside:point withEvent:event];
    if (!normalResult) {
        CGPoint the_point = [_linearLayoutView convertPoint:point fromView:self];
        if([_linearLayoutView pointInside:the_point withEvent:event]){
            return YES;
        }
    }
    return normalResult;
}

- (void) collapseStickers {
    for (STStickerDisposerView *disposer in _disposers) {
        if (disposer.disposing) {
            [disposer collapse];
        }
    }
}
- (void) stickerDisposerViewWillDispose:(STStickerDisposerView *)stickerDisposerView {
    [_linearLayoutView bringSubviewToFront:stickerDisposerView];
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerComposerWillDisposeStickers:)]) {
        [self.delegate stickerComposerWillDisposeStickers:self];
    }
}
- (void) stickerDisposerViewDidDispose:(STStickerDisposerView *)stickerDisposerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerComposerDidDisposeStickers:)]) {
        [self.delegate stickerComposerDidDisposeStickers:self];
    }
}
- (void) stickerDisposerViewWillHide:(STStickerDisposerView *)stickerDisposerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerComposerWillHideStickers:)]) {
        [self.delegate stickerComposerWillHideStickers:self];
    }
}
- (void) stickerDisposerViewDidHide:(STStickerDisposerView *)stickerDisposerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(stickerComposerDidHideStickers:)]) {
        [self.delegate stickerComposerDidHideStickers:self];
    }
}
- (void) stickerDisposerView:(STStickerDisposerView *)stickerDisposerView selectedSticker:(STSticker *)sticker {
    
}
@end
