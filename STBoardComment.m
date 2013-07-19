//
//  STBoardComment.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STBoardComment.h"

@implementation STBoardComment;

#pragma mark -
#pragma mark Factory Methods

+ (STBoardComment *) boardCommentFromJSONData:(id) json {
    if ([NSJSONSerialization isValidJSONObject:json]) {
        STBoardComment *comment = [[STBoardComment alloc] init];
        comment.commentId = json[@"id"];
        comment.userId = json[@"user_id"];
        comment.commentText = json[@"text"];
        comment.commentStickers = json[@"stickers"];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"YYYY-MM-DD hh:mm:ss";
        comment.commentTimestamp = [formatter dateFromString:json[@"timestamp"]]; //Needs to sinthesize date from string format
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

@end
