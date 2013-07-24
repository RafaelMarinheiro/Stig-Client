//
//  STOOResolvePlaceByIdFake.h
//  PJPrototype
//
//  Created by Lucas Tenório on 20/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STOverlord.h"
@interface STOOResolvePlaceByIdFake : NSObject <STOverlordOperation>
@property (nonatomic, readonly) STOverlordOperationImportance importance;
@property (nonatomic, readonly, getter = isCacheable) BOOL cacheable;
@property (nonatomic, readonly) NSNumber *placeId;
@property (nonatomic, strong) STOOResolveCompletionBlock completionBlock;
@property (nonatomic, strong) STOOErrorBlock errorBlock;
@property (nonatomic, readonly) id output;
- (id) initWithPlaceId:(NSNumber *) placeId
                   importance:(STOverlordOperationImportance) importance
                   completion:(STOOResolveCompletionBlock) completionBlock
                        error:(STOOErrorBlock) errorBlock;
- (BOOL) run;
- (void) runCompletionBlock;
- (void) runErrorBlock;
@end
