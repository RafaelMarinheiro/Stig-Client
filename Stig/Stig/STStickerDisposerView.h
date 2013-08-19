//
//  STStickerDisposerView.h
//  Stig
//
//  Created by Lucas Tenório on 17/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STSticker.h"


@protocol STStickerDisposerViewDelegate;
@interface STStickerDisposerView : UIView
@property (nonatomic, weak) IBOutlet id <STStickerDisposerViewDelegate> delegate;
@property (nonatomic ,readonly) STStickerType stickerType;
@property (nonatomic, readonly) BOOL disposing;
@property (nonatomic, readonly) STSticker *selectedSticker;
- (id) initWithStickerType:(STStickerType) type;
- (void) dispose;
- (void) collapse;
@end

@protocol STStickerDisposerViewDelegate <NSObject>
@optional
- (void) stickerDisposerViewWillDispose:(STStickerDisposerView *) stickerDisposerView;
- (void) stickerDisposerViewDidDispose:(STStickerDisposerView *) stickerDisposerView;
- (void) stickerDisposerViewWillHide:(STStickerDisposerView *) stickerDisposerView;
- (void) stickerDisposerViewDidHide:(STStickerDisposerView *) stickerDisposerView;

- (void) stickerDisposerView:(STStickerDisposerView *) stickerDisposerView selectedSticker:(STSticker *) sticker;
@end
