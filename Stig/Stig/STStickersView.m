//
//  STStickersView.m
//  Stig
//
//  Created by Lucas Tenório on 29/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STStickersView.h"

@implementation STStickersView

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
    //self.translatesAutoresizingMaskIntoConstraints = NO;
}
- (void) emptyStickers {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
    }
}
- (void) processStickers {
    if (self.stickers) {
        NSUInteger stickersCount = [self.stickers count];
        for (int i = 0; i < stickersCount; i++) {
            NSNumber *stickerId = self.stickers[i];
            UIImageView *sticker = [self imageViewForStickerId:stickerId];
            sticker.translatesAutoresizingMaskIntoConstraints = NO;
            [self addSubview:sticker];
            NSNumber *rightPadding =[NSNumber numberWithFloat:( STStickerEdgeDistance + i*STStickerSize.width + i*STSTickerSeparatorDistance)];
            NSNumber *upperPadding = [NSNumber numberWithFloat:STStickerEdgeDistance];
            NSNumber *height =[NSNumber numberWithFloat:STStickerSize.height];
            NSNumber *width = [NSNumber numberWithFloat:STStickerSize.width];

            [self addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"V:|-upperPadding-[sticker(height)]"
                                  options:0
                                  metrics:@{@"upperPadding":upperPadding,
                                        @"height":height}
                                  views:NSDictionaryOfVariableBindings(sticker)]];
            [self addConstraints:[NSLayoutConstraint
                                  constraintsWithVisualFormat:@"H:|-rightPadding-[sticker(width)]"
                                  options:0
                                  metrics:@{@"rightPadding":rightPadding,
                                  @"width":width}
                                  views:NSDictionaryOfVariableBindings(sticker)]];

            
        }
    }
}
- (void) setStickers:(NSArray *)stickers {
    _stickers = stickers;
    [self emptyStickers];
    [self processStickers];
    [self invalidateIntrinsicContentSize];
}
- (CGSize) intrinsicContentSize {
    NSUInteger stickerCount = [self.stickers count];
    CGFloat width = 2*STStickerEdgeDistance + stickerCount*STStickerSize.width;
    if (stickerCount) {
        width+=(stickerCount-1)*STSTickerSeparatorDistance;
    }
    CGFloat height = 2*STStickerEdgeDistance + MIN(stickerCount, 1) * STStickerSize.height;
    return CGSizeMake(width, height);
}
- (UIImageView *) imageViewForStickerId:(NSNumber *) stickerId {
    UIImage *image = [UIImage imageNamed:[self imageNameForStickerId:stickerId]];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(0.0, 0.0, STStickerSize.width, STStickerSize.height);
    return imageView;
}
- (NSString *) imageNameForStickerId:(NSNumber *) stickerId {
    NSUInteger intValue = [stickerId integerValue];

    switch (intValue) {
        case 0:
            return @"icone_acesso_44";
        case 1:
            return @"icone_drink_44";
        case 2:
            return @"icone_fila_44";
        case 3:
            return @"icone_money_44";
        case 4:
            return @"icone_music_44";
        case 5:
            return @"icone_people_44";
    }
    return @"uk-board.jpg";
}

@end
