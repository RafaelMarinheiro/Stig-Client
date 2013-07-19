//
//  STDataOverlord.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOverlord.h"
#import "STOverlordOperationSearchFakePlace.h"
#import "STOverlordOperationGetUserByIDFake.h"
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
#pragma mark Creating Operations
- (void) searchPlaceBySearchTerm:(NSString *) term
                      completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                           error:(STOverlordErrorBlock) errorBlock {
    [self searchPlaceBySearchTerm:term
                       importance:STOverlordOperationImportanceNormal
                       requestNew:YES
                       completion:completionBlock
                            error:errorBlock];
}
- (void) searchPlaceBySearchTerm:(NSString *)term
                      importance:(STOverlordOperationImportance)importance
                      requestNew:(BOOL)requestNew
                      completion:(void (^)(NSArray *, NSUInteger))completionBlock
                           error:(void (^)(NSError *))errorBlock {
    STOverlordOperationSearchFakePlace *operation = [[STOverlordOperationSearchFakePlace alloc]
                                                     initWithLocation:self.userLocation
                                                     searchTerm:term
                                                     pageNumber:0
                                                     importance:importance
                                                     completion:completionBlock
                                                     error:errorBlock];
    [self runOperation:operation];
}
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *))completionBlock
                   error:(STOverlordErrorBlock)errorBlock {
    [self resolveUserById:userId
               importance:STOverlordOperationImportanceNormal
               requestNew:YES
               completion:completionBlock
                    error:errorBlock];
}
- (void) resolveUserById:(NSNumber *)userId
              importance:(STOverlordOperationImportance)importance
              requestNew:(BOOL)requestNew
              completion:(void (^)(STUser *))completionBlock
                   error:(STOverlordErrorBlock)errorBlock {
    
    STOverlordOperationGetUserByIDFake *operation = [[STOverlordOperationGetUserByIDFake alloc]
                                                     initWithUserId:userId
                                                     importance:importance
                                                     completion:completionBlock
                                                     error:errorBlock];
    [self runOperation:operation];
}
@end
