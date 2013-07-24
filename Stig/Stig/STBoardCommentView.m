//
//  STBoardCommentView.m
//  PJPrototype
//
//  Created by Lucas Tenório on 21/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardCommentView.h"

@implementation STBoardCommentView
- (void) populateCommentWithText:(NSString *) commentText userName:(NSString *)userName userImageURL:(NSString *) userImageURL andTimestamp:(NSDate *)timestamp {
    UIColor *nameColor = [UIColor colorWithRed:114.0/255.0 green:73.0/255.0 blue:227.0/255.0 alpha:1.0];
    
    NSDictionary *nameAttributes = @{NSFontAttributeName:self.userNameFont,NSForegroundColorAttributeName:nameColor};
    
    NSDictionary *commentAttributes = @{NSFontAttributeName:self.commentFont,NSForegroundColorAttributeName:[UIColor blackColor]};
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", commentText] attributes:commentAttributes];
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:userName attributes:nameAttributes];

    
    [nameString appendAttributedString:commentString];
    self.commentLabel.attributedText = nameString;
    [self.commentLabel sizeToFit];
    
    [self.userImageView setImageWithURL:[NSURL URLWithString:userImageURL]];
}
- (CGFloat) cellHeight {
    return 2.0*10.0 + self.commentLabel.frame.size.height;
}
@end
