//
//  STOverlordOperationGetCommentsByIdFake.h
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STOverlord.h"

@interface STOOResolveCommentsByIdFake : NSObject <STOverlordOperation>
@property (nonatomic, readonly) STOverlordOperationImportance importance;
@property (nonatomic, readonly, getter = isCacheable) BOOL cacheable;
@property (nonatomic, readonly) NSNumber *commentId;
@property (nonatomic, strong) void (^completionBlock)(STBoardComment *comment);
@property (nonatomic, strong) STOOErrorBlock errorBlock;
@property (nonatomic, readonly) id output;
- (id) initWithBoardCommentId:(NSNumber *) commentId
           importance:(STOverlordOperationImportance) importance
           completion:(void (^)(STBoardComment *comment)) completionBlock
                error:(STOOErrorBlock) errorBlock;
- (BOOL) run; 
- (void) runCompletionBlock;
- (void) runErrorBlock;
@end
