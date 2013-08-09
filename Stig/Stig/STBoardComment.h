//
//  STBoardComment.h
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STBoardComment : NSObject


@property (nonatomic, strong) NSNumber *commentId;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber *placeId;
@property (nonatomic, strong) NSNumber *replyId;
@property (nonatomic, strong) NSString *commentText;
@property (nonatomic, strong) NSArray *commentStickers;
@property (nonatomic, strong) NSDate *commentTimestamp;
+ (STBoardComment *) boardCommentFromJSONData:(id) json;
+ (STBoardComment *) boardCommentWithId:(NSNumber *)commentId andJSONData:(id)json;
@end
