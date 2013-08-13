//
//  STStickersView.m
//  Stig
//
//  Created by Lucas Tenório on 29/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STCommentStickerView.h"
#import "STLinearLayoutView.h"
#import "STSticker.h"
@implementation STCommentStickerView {
    STLinearLayoutView *_layoutView;
}

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
- (BOOL) translatesAutoresizingMaskIntoConstraints {
    return NO;
}
- (void) config {
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisVertical];
}
- (void) processStickers {
    
    NSUInteger stickersCount = [self.stickers count];
    NSMutableArray *imageViews = [NSMutableArray arrayWithCapacity:stickersCount];
    for (int i = 0; i < stickersCount; i++) {
        NSNumber *stickerId = self.stickers[i];
        UIImageView *sticker = [self imageViewForStickerId:stickerId];
        [imageViews addObject:sticker];
    }
    _layoutView = [[STLinearLayoutView alloc] initWithViews:imageViews viewSize:CGSizeMake(30.0, 30.0) viewSeparator:0.0 andEdgeSeparator:0.0];
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

}
- (void) setStickers:(NSArray *)stickers {
    if (!_layoutView) {
        _stickers = stickers;
        [self processStickers];
        [self invalidateIntrinsicContentSize];
    }
}
- (CGSize) intrinsicContentSize {
    if (_layoutView) {
        return [_layoutView intrinsicContentSize];
    }else{
        return [super intrinsicContentSize];
    }
}
- (UIImageView *) imageViewForStickerId:(NSNumber *) stickerId {
    STSticker *sticker = [[STSticker alloc] initWithId:stickerId];
    UIImage *image = [sticker stickerIconWithPlace:@"selector"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0.0, 0.0, STStickerSize.width, STStickerSize.height);
    return imageView;
}
@end
