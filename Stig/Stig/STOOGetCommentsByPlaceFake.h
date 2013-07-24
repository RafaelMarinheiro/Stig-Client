//
//  STOverlordOperationGetCommentsByPlaceFake.h
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STOverlord.h"

@interface STOOGetCommentsByPlaceFake : NSObject <STOverlordOperation>
@property (nonatomic, readonly) STOverlordOperationImportance importance;
@property (nonatomic, readonly, getter = isCacheable) BOOL cacheable;

@property (nonatomic, strong) STLocation *location;
@property (nonatomic, strong) STPlace *place;
@property (nonatomic, strong) NSArray *stickers;
@property (nonatomic) NSUInteger pageNumber;
@property (nonatomic, strong) void (^completionBlock)(NSArray *places, NSUInteger page);
@property (nonatomic, strong) STOOErrorBlock errorBlock;
@property (nonatomic, readonly) id output;
- (id) initWithLocation:(STLocation *)location
                  place:(STPlace *) place
               stickers:(NSArray *) stickers
             pageNumber:(NSUInteger) pageNumber
             importance:(STOverlordOperationImportance) importance
             completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                  error:(STOOErrorBlock) errorBlock;

- (BOOL) run;
- (void) runCompletionBlock;
- (void) runErrorBlock;
@end
