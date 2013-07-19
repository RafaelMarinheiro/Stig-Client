//
//  STOverlord.h
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STBoardComment.h"
#import "STUser.h"
#import "STPlace.h"
#import "STLocation.h"
typedef enum{
    STOverlordOperationImportanceHigh,      //Should be used for high level operations like requesting information from a place
    STOverlordOperationImportanceNormal,    //Should be used for normal operations, like loading the comments related to a place
    STOverlordOperationImportanceLow        //Should be used for low level operations, like caching the previous comments or other informations
}STOverlordOperationImportance;
typedef void(^STOverlordErrorBlock)(NSError *error);
//@protocol STOverlordOperation;

@interface STOverlord : NSObject


@property (nonatomic, strong,readonly) STLocation *userLocation;


+ (id) sharedInstance;
//Ideally, all the information return should be cached by the Overlord, so if if you know there is a high probability for you
//to need something in the future, just ask the Overlord to resolve the information you need and send nil as a completion block,
//the next time you ask for the same thing, the Overlord should have your information really fast

//Convenience methods, the default importance is STOverlordOperationImportanceNormal and the default requestNew is NO 
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *user)) completionBlock
                   error:(STOverlordErrorBlock) errorBlock;
- (void) resolveBoardCommentById:(NSNumber *) commentId
                      completion:(void (^)(STBoardComment *place)) completionBlock
                           error:(STOverlordErrorBlock) errorBlock;
- (void) resolvePlaceById:(NSNumber *) placeId
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock;
- (void) searchPlaceBySearchTerm:(NSString *) term
                      completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                           error:(STOverlordErrorBlock) errorBlock;
- (void) getCommentsFromPlace:(STPlace *) place
                 withStickers:(NSArray *) stickers
                   completion:(void (^)(NSArray *comments)) completionBlock
                        error:(STOverlordErrorBlock) errorBlock;


- (void) resolveUserById:(NSNumber *)userId
              importance:(STOverlordOperationImportance) importance
              requestNew:(BOOL) requestNew
              completion:(void (^)(STUser *place)) completionBlock
                   error:(STOverlordErrorBlock) errorBlock;

- (void) resolveBoardCommentById:(NSNumber *) commentId
                      importance:(STOverlordOperationImportance) importance
                      requestNew:(BOOL) requestNew
                      completion:(void (^)(STBoardComment *place)) completionBlock
                           error:(STOverlordErrorBlock) errorBlock;
- (void) resolvePlaceById:(NSNumber *) placeId
               importance:(STOverlordOperationImportance) importance
               requestNew:(BOOL) requestNew
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(STOverlordErrorBlock) errorBlock;
- (void) searchPlaceBySearchTerm:(NSString *) term
                    importance:(STOverlordOperationImportance) importance
                    requestNew:(BOOL) requestNew
                    completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                         error:(STOverlordErrorBlock) errorBlock;
- (void) getCommentsFromPlace:(STPlace *) place
                 withStickers:(NSArray *) stickers
                   importance:(STOverlordOperationImportance) importance
                   requestNew:(BOOL) requestNew
                   completion:(void (^)(NSArray *comments)) completionBlock
                        error:(STOverlordErrorBlock) errorBlock;
- (void)updateLocation:(STLocation *) location;
- (void) updateCaches; //The Overlord will re-cache everything, he will use STOverlordImportanceLow to do this
- (void) deleteCaches; //If memory is low, call this. This may occur, because the overlord will try to cache everything it resolves
@end


@protocol STOverlordOperation <NSObject>
@required
@property (nonatomic, readonly) STOverlordOperationImportance importance;
@property (nonatomic, readonly, getter = isCacheable) BOOL cacheable;
@property (nonatomic, readonly) id output;
- (BOOL) run; //This method is called when the operation must process the inputs and return if it was successful. By the end of the process, the output must have a valid answer or a NSError 
- (void) runCompletionBlock;
- (void) runErrorBlock;
@end
