//
//  STStickerDisposerView.h
//  Stig
//
//  Created by Lucas Tenório on 17/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSticker.h"
@interface STStickerDisposerView : UIView
@property (nonatomic) STStickerType stickerType;
@property (nonatomic, readonly) BOOL disposing;
@end
