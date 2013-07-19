//
//  STOverlordOperationGetUserByIDFake.h
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STOverlord.h"

@interface STOOResolveUserByIDFake : NSObject< STOverlordOperation>

@property (nonatomic, readonly) STOverlordOperationImportance importance;
@property (nonatomic, readonly, getter = isCacheable) BOOL cacheable;
@property (nonatomic, readonly) NSNumber *userId;
@property (nonatomic, strong) void (^completionBlock)(STUser *user);
@property (nonatomic, strong) STOErrorBlock errorBlock;
@property (nonatomic, readonly) id output;
- (id) initWithUserId:(NSNumber *) userId
           importance:(STOverlordOperationImportance) importance
           completion:(void (^)(STUser *user)) completionBlock
                error:(STOErrorBlock) errorBlock;
- (BOOL) run;
- (void) runCompletionBlock;
- (void) runErrorBlock;
@end
