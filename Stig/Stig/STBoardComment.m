//
//  STBoardComment.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardComment.h"
#import "STSticker.h"
@implementation STBoardComment;

#pragma mark -
#pragma mark Factory Methods

+ (STBoardComment *) boardCommentFromJSONData:(id) json {
    if ([NSJSONSerialization isValidJSONObject:json]) {
        STBoardComment *comment = [[STBoardComment alloc] init];
        comment.commentId = json[@"id"];
        comment.userId = json[@"user_id"];
        comment.commentText = json[@"text"];
        comment.placeId = json[@"place_id"];
        comment.replyId = nil;
        NSArray *stickerIds = json[@"stickers"];
        NSMutableArray * stickers =  [[NSMutableArray alloc] initWithCapacity:stickerIds.count];
        for (NSNumber *stickerId in stickerIds) {
            [stickers addObject: [[STSticker alloc] initWithId:stickerId]];
        }
        comment.commentStickers = stickers;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        comment.commentTimestamp = [formatter dateFromString:json[@"timestamp"]];
        return comment;
    }

    return nil;
}

+ (STBoardComment *) boardCommentFromServerJSONData:(id) json {
    if ([NSJSONSerialization isValidJSONObject:json]) {
        STBoardComment *comment = [[STBoardComment alloc] init];
        comment.commentId = json[@"id"];
        comment.userId = json[@"user"];
        comment.commentText = json[@"content"];
        comment.placeId = json[@"place"];
        comment.replyId = nil;
        comment.commentStickers = [STSticker stickersWithServerCode:[json[@"stickers"] unsignedIntegerValue]];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ";
        comment.commentTimestamp = [formatter dateFromString:json[@"created_on"]];
        comment.userLike = json[@"thumbs_by_me"];
        NSLog(@"Comment json [%@]", json);
        return comment;
    }
    
    return nil;
}

+ (STBoardComment *) boardCommentWithId:(NSNumber *)commentId andJSONData:(id)json {
    if([NSJSONSerialization isValidJSONObject:json]){
        
        if([json isKindOfClass:[NSDictionary class]]){
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:json];
            [dictionary setObject:commentId forKey:@"id"];
            return [STBoardComment boardCommentFromJSONData:dictionary];
            
        }
    }
    return nil;
}
- (NSString *) description {
    return [NSString stringWithFormat:@"[%@: %@, %@, %@, [%@]]",self.commentId,self.userId,self.commentText,self.commentTimestamp, self.commentStickers];
}
@end
