//
//  STBoardCommentView.h
//  PJPrototype
//
//  Created by Lucas Tenório on 21/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+AFNetworking.h"
#import "STStickersView.h"
@interface STBoardCommentView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *userImageView;
@property (nonatomic, weak) IBOutlet UITextView *commentLabel;
@property (nonatomic, strong) UIFont *commentFont;
@property (nonatomic, strong) UIFont *userNameFont;
- (void) populateCommentWithText:(NSString *) commentText userName:(NSString *)userName userImageURL:(NSString *) userImageURL andTimestamp:(NSDate *)timestamp;
@property (nonatomic, readonly) CGFloat cellHeight;
@property (nonatomic, weak) IBOutlet STStickersView *stickersView;
@end
