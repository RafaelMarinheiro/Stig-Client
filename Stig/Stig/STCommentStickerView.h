//
//  STStickersView.h
//  Stig
//
//  Created by Lucas Tenório on 29/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
static CGSize const STStickerSize = {30.0,30.0};
static CGFloat const STStickerEdgeDistance = 0.0;
static CGFloat const STSTickerSeparatorDistance = 0.0;


@interface STCommentStickerView : UIView
@property (nonatomic, strong) NSArray *stickers;
@end
