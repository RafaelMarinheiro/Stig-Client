//
//  STStickerSelectorView.m
//  Stig
//
//  Created by Lucas Tenório on 31/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STStickerSelectorView.h"
#import "STLinearLayoutView.h"

@implementation STStickerSelectorView {
    STLinearLayoutView *_layoutView;
}
- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}
- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (void) config {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSMutableArray *buttons = [NSMutableArray arrayWithCapacity:6];
    for (int i = 0; i < 6; i++) {
        NSNumber *stickerId = @(i);
        UIButton *stickerButton = [self buttonForStickerId:stickerId];
        [buttons addObject:stickerButton];
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
- (UIButton *) buttonForStickerId:(NSNumber *) stickerId {
    UIImage *image = [UIImage imageNamed:[self imageNameForStickerId:stickerId]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:image forState:UIControlStateNormal];
    
    return button;
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
