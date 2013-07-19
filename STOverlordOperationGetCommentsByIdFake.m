//
//  STOverlordOperationGetCommentsByIdFake.m
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOverlordOperationGetCommentsByIdFake.h"

@implementation STOverlordOperationGetCommentsByIdFake
- (id) initWithBoardCommentId:(NSNumber *) commentId importance:(STOverlordOperationImportance) importance completion:(void (^)(STBoardComment *comment)) completionBlock error:(STOverlordErrorBlock) errorBlock {
    self = [super init];
    if (self) {
        _importance = importance;
        _cacheable = YES;
        _commentId = commentId;
        self.completionBlock = completionBlock;
        self.errorBlock = errorBlock;
    }
    return self;
}
- (BOOL) run {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakeComments" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (json) {
        NSDictionary *mainDictionary = json;
        NSArray *commentsJSON = mainDictionary[@"comments"];
        for (NSDictionary *commentDictionary in commentsJSON) {
            NSNumber *commentId = commentDictionary[@"id"];
            if ([commentId isEqualToNumber:self.commentId]) {
                STBoardComment *comment = [STBoardComment boardCommentFromJSONData:commentDictionary];
                _output = comment;
                return YES;
            }
        }
        _output = [NSError errorWithDomain:@"comment not found or error in json" code:2 userInfo:nil];
        return NO;
    }  else {
        _output = error;
        return NO;
    }
}
- (void) runCompletionBlock {
    self.completionBlock(self.output);
}
- (void) runErrorBlock {
    self.errorBlock(self.output);
}
@end
