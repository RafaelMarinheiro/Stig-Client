//
//  STBoardCommentView.m
//  PJPrototype
//
//  Created by Lucas Tenório on 21/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardCommentView.h"

@implementation STBoardCommentView{
    NSAttributedString *_commentString;
}
- (void) populateCommentWithText:(NSString *) commentText userName:(NSString *)userName userImageURL:(NSString *) userImageURL andTimestamp:(NSDate *)timestamp {
    UIColor *nameColor = [UIColor colorWithRed:114.0/255.0 green:73.0/255.0 blue:227.0/255.0 alpha:1.0];
    
    NSDictionary *nameAttributes = @{NSFontAttributeName:self.userNameFont,
                                     NSForegroundColorAttributeName:nameColor};
    
    NSDictionary *commentAttributes = @{NSFontAttributeName:self.commentFont,
                                        NSForegroundColorAttributeName:[UIColor blackColor]};
    NSAttributedString *commentString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n%@\n", commentText] attributes:commentAttributes];

    NSString *time = [self niceTimeInterval:[timestamp timeIntervalSinceNow]];
    
    NSDictionary *timeAttributes = @{NSFontAttributeName:[self.commentFont fontWithSize:13.0],
                                     NSForegroundColorAttributeName:[[UIColor blackColor] colorWithAlphaComponent:0.7]};

    NSAttributedString *timeString = [[NSAttributedString alloc] initWithString:time attributes:timeAttributes];

    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:userName attributes:nameAttributes];

    

    [nameString appendAttributedString:commentString];
    [nameString appendAttributedString:timeString];
    _commentString = nameString;
    self.commentLabel.attributedText = nameString;
    [self.commentLabel sizeToFit];
    
    [self.userImageView setImageWithURL:[NSURL URLWithString:userImageURL]];
}
- (CGFloat) cellHeight {
    CGRect rect = [_commentString boundingRectWithSize:CGSizeMake(230.0, 10000) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
    return 2.0*10.0 + rect.size.height;
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
