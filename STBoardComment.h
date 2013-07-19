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
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSArray *stickers;
@property (nonatomic, strong) NSDate *timestamp;
+ (STBoardComment *) boardCommentFromJSONData:(id) json;
+ (STBoardComment *) boardCommentWithId:(NSNumber *)commentId andJSONData:(id)json;
@end
