//
//  STBoardCommentView.m
//  PJPrototype
//
//  Created by Lucas Tenório on 21/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardCommentView.h"
#import <QuartzCore/QuartzCore.h>

@implementation STBoardCommentView;

#pragma mark - Initialization
- (id) initWithFrame:(CGRect)frame{
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

- (void) config {
    [self setupViews];
    [self setupConstraints];
}
- (void) setupViews {
    _userImageView = [[UIImageView alloc] init];
    [_userImageView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mainSwipeView addSubview:_userImageView];

    _commentLabel = [[UITextView alloc] init];
    [_commentLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mainSwipeView addSubview:_commentLabel];
    [_commentLabel setEditable:NO];
    [_commentLabel setUserInteractionEnabled:NO];

    _commentLabel.contentInset = UIEdgeInsetsMake(8, 0, -8, 0);

    _stickersView = [[STCommentStickerView alloc] init];
    [_stickersView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.mainSwipeView addSubview:_stickersView];
    UIColor * mainColor = [UIColor colorWithRed:242.0/255 green:242.0/255 blue:242.0/255 alpha:1.0];
    _commentLabel.backgroundColor = mainColor;
    self.backgroundColor = mainColor;
    self.mainSwipeView.backgroundColor = mainColor;

    [self.mainSwipeView bringSubviewToFront:self.leftIndicatorView];
    [self.mainSwipeView bringSubviewToFront:self.rightIndicatorView];
    

}

- (void) setupConstraints {

    [self.mainSwipeView addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"H:|-(12)-[_userImageView(50)]"
                                        options:0
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(_userImageView)]];
    
    [self.mainSwipeView addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"V:|-(12)-[_userImageView(50)]"
                                        options:0
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(_userImageView)]];
    
    [self.mainSwipeView addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"V:[_userImageView]-0-[_stickersView]"
                                        options:NSLayoutFormatAlignAllCenterX
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(_userImageView,_stickersView)]];

    [self.mainSwipeView addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"H:[_userImageView]-(0)-[_commentLabel]-(0)-|"
                                        options:0
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(_userImageView,_commentLabel)]];
    
    [self.mainSwipeView addConstraints:[NSLayoutConstraint
                                        constraintsWithVisualFormat:@"V:|[_commentLabel]|"
                                        options:0
                                        metrics:nil
                                        views:NSDictionaryOfVariableBindings(_commentLabel)]];
}

#pragma mark - Reuse 
- (void) prepareForReuse {
    [super prepareForReuse];
    self.currentComment = nil;
    self.commentLabel.text = @"Loading...";
    self.stickersView.stickers = nil;
    [self.userImageView setImage:[UIImage imageNamed:@"placeholder_user"]];
    _cellHeight = 80.0;
}
- (void) populateWithComment:(STBoardComment *)comment andUser:(STUser *)user {
    self.currentComment = comment;
    self.commentLabel.attributedText = [self textWithComment:comment andUser:user];

    if([comment.userLike integerValue] == -1) {
        self.selectionStatus = STSwipeViewSelectionStatusRight;
    }else if ([comment.userLike integerValue] == 1){
        self.selectionStatus = STSwipeViewSelectionStatusLeft;
    }else{
        self.selectionStatus = STSwipeViewSelectionStatusNone;
    }
    self.stickersView.stickers = comment.commentStickers;
    [self.stickersView setNeedsLayout];
    [self.stickersView layoutIfNeeded];
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.userImageURL]];
    [self.userImageView setContentMode:UIViewContentModeScaleAspectFill];
    [self.userImageView.layer setCornerRadius:5.0];
    self.userImageView.layer.masksToBounds = YES;
    CGFloat h = self.userImageView.frame.size.height  + 14 + self.stickersView.frame.size.height;
    _cellHeight = MAX(h,  self.commentLabel.contentSize.height);
    self.swipeEnabled = YES;
}

#pragma mark - Text appearance
- (NSAttributedString *) textWithComment:(STBoardComment *) comment andUser:(STUser *) user {
    NSMutableAttributedString *nameString = [[self attributedUserNameStringWithUser:user] mutableCopy];
    [nameString appendAttributedString:[self attributedCommentTextStringWithComment:comment]];
    [nameString appendAttributedString:[self attributedTimestampStringWithDate:comment.commentTimestamp]];
    return nameString;
}
- (NSAttributedString *) attributedUserNameStringWithUser:(STUser *) user {
    UIFont *userNameFont = [UIFont fontWithName:@"Futura" size:16.0];
    UIColor *nameColor = [UIColor colorWithRed:48.0/255.0 green:48.0/255.0 blue:48.0/255.0 alpha:1.0];
    NSDictionary *nameAttributes = @{NSFontAttributeName:userNameFont,
                                     NSForegroundColorAttributeName:nameColor};
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:user.userName attributes:nameAttributes];
    return nameString;
}
- (NSAttributedString *) attributedTimestampStringWithDate:(NSDate *) date {
    UIFont *timeFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    UIColor *timeColor = [UIColor colorWithRed:91.0/255.0 green:91.0/255.0 blue:91.0/255.0 alpha:7.0];
    NSString *time = [self niceTimeInterval:[date timeIntervalSinceNow]];
    NSMutableParagraphStyle *mutParaStyle=[[NSMutableParagraphStyle alloc] init];
    [mutParaStyle setAlignment:NSTextAlignmentLeft];
    NSDictionary *timeAttributes = @{NSFontAttributeName:[timeFont fontWithSize:13.0],
                                     NSForegroundColorAttributeName:[timeColor colorWithAlphaComponent:0.8],
                                     NSParagraphStyleAttributeName:mutParaStyle};
    
    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:time attributes:timeAttributes];
    return timeString;
}
- (NSAttributedString *) attributedCommentTextStringWithComment:(STBoardComment *) comment {
    UIFont *commentFont = [UIFont fontWithName:@"Helvetica" size:14.0];
    UIColor *commentColor = [UIColor colorWithRed:85.0/255.0 green:85.0/255.0 blue:85.0/255.0 alpha:1.0];
    NSDictionary *commentAttributes = @{NSFontAttributeName:commentFont,
                                        NSForegroundColorAttributeName:commentColor};
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n", comment.commentText] attributes:commentAttributes];
    return commentString;
}

- (NSString *) niceTimeInterval:(NSTimeInterval) time {
    time = - time;
    NSUInteger intTime = time;
    
    if (time < 60) {
        return [NSString stringWithFormat:@"%d seconds ago",intTime];
    } else {
        NSUInteger minutes = intTime / 60;
        if (minutes < 60) {
            return [NSString stringWithFormat:@"%d minutes ago",minutes];
        } else{
            NSUInteger hours = minutes / 60;
            if (hours < 24) {
                return [NSString stringWithFormat:@"%d hours ago", hours];
            }else {
                NSUInteger days = hours / 24;
                return [NSString stringWithFormat:@"%d days ago", days];
            }
        }
    }
}

@end
