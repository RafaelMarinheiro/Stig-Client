//
//  STStickerSelectorView.h
//  Stig
//
//  Created by Lucas Tenório on 31/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSticker.h"

@protocol STStickerPickerViewDelegate;

@interface STStickerPickerView : UIView
@property (nonatomic, weak) IBOutlet id <STStickerPickerViewDelegate> delegate;
- (void) setStickersWithIds:(NSArray *) stickerIds;
- (void) setSticker:(STSticker *) sticker;
- (id) initWithStickerModifier:(STSTickerModifier) modifier;
@end

@protocol STStickerPickerViewDelegate <NSObject>
@optional
- (void) stickerPicker:(STStickerPickerView *) stickerPicker stickerPicked:(STSticker *) sticker;
@end
