//
//  STDataOverlord.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOverlord.h"
#import "STOOGetPlacesFake.h"
#import "STOOResolveUserByIDFake.h"
#import "STOOResolveCommentsByIdFake.h"
#import "STOOResolvePlaceByIdFake.h"
#import "STOOGetCommentsByPlaceFake.h"

//First implementation of the Overlord, completely naive, should be better but fuck it...
@implementation STOverlord {
    dispatch_queue_t _highImportanceQueue;
    dispatch_queue_t _normalImportanceQueue;
    dispatch_queue_t _lowImportanceQueue;
}
#pragma mark-
#pragma mark Initialization
+ (id) sharedInstance {
    static STOverlord *overlord = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        overlord = [[self alloc] init];
    });
    return overlord;
}
- (id) init {
    self = [super init];
    if (self) {
        _highImportanceQueue = dispatch_queue_create("STOverlordHighPriorityQueue", DISPATCH_QUEUE_SERIAL);
        _normalImportanceQueue = dispatch_queue_create("STOverlordNormalPriorityQueue", DISPATCH_QUEUE_SERIAL);
        _lowImportanceQueue = dispatch_queue_create("STOverlordLowPriorityQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}
#pragma mark-
#pragma mark Overlord Management
- (void)updateLocation:(STLocation *) location {
    //Should update location sensitive caches if the location change is big enough
}
- (void) updateCaches{
    //Do the dancex
}
- (void) deleteCaches {
    //Dance more...
}
#pragma mark-
#pragma mark Managing Queues
- (dispatch_queue_t) queueForImportance:(STOverlordOperationImportance) importance {
    if (importance == STOverlordOperationImportanceHigh) {
        return _highImportanceQueue;
    } else if(importance == STOverlordOperationImportanceNormal) {
        return _normalImportanceQueue;
    } else {
        return _lowImportanceQueue;
    }
}

#pragma mark-
#pragma mark Running Operations
- (void) runOperation:(id <STOverlordOperation>) operation {
    dispatch_queue_t queue = [self queueForImportance:operation.importance];
    dispatch_async(queue, ^{
        BOOL completed = [operation run];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed) {
                [operation runCompletionBlock];
            }else {
                [operation runErrorBlock];
            }
        });
    });
}

#pragma mark-
#pragma mark 'Get' STOOs

- (void) getPlacesWithSearchTerm:(NSString *)term
                      pageNumber:(NSUInteger) pageNumber
                      importance:(STOverlordOperationImportance)importance
                      requestNew:(BOOL)requestNew
                      completion:(void (^)(NSArray *, NSUInteger))completionBlock
                           error:(void (^)(NSError *))errorBlock {
    STOOGetPlacesFake *operation = [[STOOGetPlacesFake alloc]
                                                     initWithLocation:self.userLocation
                                                     searchTerm:term
                                                     pageNumber:pageNumber
                                                     importance:importance
                                                     completion:completionBlock
                                                     error:errorBlock];
    [self runOperation:operation];
}

- (void) getCommentsFromPlace:(STPlace *)place
                 withStickers:(NSArray *)stickers
                   pageNumber:(NSUInteger) pageNumber
                   importance:(STOverlordOperationImportance)importance
                   requestNew:(BOOL)requestNew
                   completion:(STOOGetCompletionBlock)completionBlock
                        error:(STOOErrorBlock)errorBlock {
    STOOGetCommentsByPlaceFake *operation = [[STOOGetCommentsByPlaceFake alloc]
                                             initWithLocation:self.userLocation
                                             place:place stickers:stickers
                                             pageNumber:pageNumber
                                             importance:importance
                                             completion:completionBlock
                                             error:errorBlock];
    [self runOperation:operation];
}
#pragma mark-
#pragma mark 'Resolve' STOOs

- (void) resolveUserById:(NSNumber *)userId
              importance:(STOverlordOperationImportance)importance
              requestNew:(BOOL)requestNew
              completion:(void (^)(STUser *))completionBlock
                   error:(STOOErrorBlock)errorBlock {
    
    STOOResolveUserByIDFake *operation = [[STOOResolveUserByIDFake alloc]
                                                     initWithUserId:userId
                                                     importance:importance
                                                     completion:completionBlock
                                                     error:errorBlock];
    [self runOperation:operation];
}

- (void) resolveBoardCommentById:(NSNumber *)commentId
                      importance:(STOverlordOperationImportance)importance
                      requestNew:(BOOL)requestNew
                      completion:(void (^)(STBoardComment *))completionBlock
                           error:(STOOErrorBlock)errorBlock {
    STOOResolveCommentsByIdFake *operation = [[STOOResolveCommentsByIdFake alloc]
                                                         initWithBoardCommentId:commentId
                                                         importance:importance
                                                         completion:completionBlock
                                                         error:errorBlock];
    [self runOperation:operation];
}
- (void) resolvePlaceById:(NSNumber *)placeId
               importance:(STOverlordOperationImportance)importance
               requestNew:(BOOL)requestNew
               completion:(void (^)(STPlace *))completionBlock
                    error:(STOOErrorBlock)errorBlock{
    STOOResolvePlaceByIdFake *operation = [[STOOResolvePlaceByIdFake alloc]
                                           initWithPlaceId:placeId importance:importance completion:completionBlock error:errorBlock];
    [self runOperation:operation];
}
#pragma mark -
#pragma mark Convenience Methods
- (void) getPlacesWithSearchTerm:(NSString *) term
                      pageNumber:(NSUInteger) pageNumber
                      completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                           error:(STOOErrorBlock) errorBlock {
    [self getPlacesWithSearchTerm:term
                       pageNumber:pageNumber
                       importance:STOverlordOperationImportanceNormal
                       requestNew:NO
                       completion:completionBlock
                            error:errorBlock];
}
- (void) getCommentsFromPlace:(STPlace *)place
                 withStickers:(NSArray *)stickers
                   pageNumber:(NSUInteger)pageNumber
                   completion:(STOOGetCompletionBlock)completionBlock
                        error:(STOOErrorBlock)errorBlock {
    [self getCommentsFromPlace:place
                  withStickers:stickers
                    pageNumber:pageNumber
                    importance:STOverlordOperationImportanceNormal
                    requestNew:NO
                    completion:completionBlock
                         error:errorBlock];
}
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *))completionBlock
                   error:(STOOErrorBlock)errorBlock {
    [self resolveUserById:userId
               importance:STOverlordOperationImportanceNormal
               requestNew:YES
               completion:completionBlock
                    error:errorBlock];
}
- (void) resolveBoardCommentById:(NSNumber *)commentId
                      completion:(void (^)(STBoardComment *))completionBlock
                           error:(STOOErrorBlock)errorBlock {
    return [self resolveBoardCommentById:commentId importance:STOverlordOperationImportanceNormal requestNew:YES completion:completionBlock error:errorBlock];
}
- (void) resolvePlaceById:(NSNumber *)placeId completion:(void (^)(STPlace *))completionBlock error:(void (^)(NSError *))errorBlock{
    [self resolvePlaceById:placeId importance:STOverlordOperationImportanceNormal requestNew:NO completion:completionBlock error:errorBlock];
}
@end
