//
//  STBoardCommentView.h
//  PJPrototype
//
//  Created by Lucas Tenório on 21/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "STCommentStickerView.h"
#import "STBoardComment.h"
#import "STUser.h"
#import "STSwipeView.h"
@interface STBoardCommentView : STSwipeView

@property (nonatomic, strong)  UIImageView *userImageView;
@property (nonatomic, strong)  UITextView *commentLabel;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, strong)  STCommentStickerView *stickersView;
- (void) populateWithComment:(STBoardComment *) comment andUser:(STUser *) user;
- (void) prepareForReuse;
@end
