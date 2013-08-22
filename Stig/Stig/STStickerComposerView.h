//
//  STStickerComposerView.h
//  Stig
//
//  Created by Lucas Tenório on 13/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STStickerPickerView.h"
#import "STStickerDisposerView.h"
@protocol STStickerComposerDelegate;
@interface STStickerComposerView : UIView <STStickerDisposerViewDelegate>
@property (nonatomic, weak) id <STStickerComposerDelegate> delegate;
@property (nonatomic, strong, readonly) NSArray *selectedStickers;
- (void) collapseStickers;

@end

@protocol STStickerComposerDelegate <NSObject>
@optional
- (void) stickerComposerWillDisposeStickers:(STStickerComposerView *) composer;
- (void) stickerComposerDidDisposeStickers:(STStickerComposerView *) composer;
- (void) stickerComposerWillHideStickers:(STStickerComposerView *) composer;
- (void) stickerComposerDidHideStickers:(STStickerComposerView *) composer;

@end
