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


@interface STOverlord : NSObject
//Ideally, all the information return should be cached by the Overlord, so if if you know there is a high probability for you
//to need something in the future, just ask the Overlord to resolve the information you need and send nil as a completion block,
//the next time you ask for the same thing, the Overlord should have your information really fast

//Convenience methods, the default importance is STOverlordOperationImportanceNormal and the default requestNew is NO 
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *place)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock;
- (void) resolveBoardCommentById:(NSNumber *) commentId
                      completion:(void (^)(STBoardComment *place)) completionBlock
                           error:(void (^)(NSError *error)) errorBlock;
- (void) resolvePlaceById:(NSNumber *) placeId
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock;
- (void) searchPlaceByLocation:(STLocation *) location
                    completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                         error:(void (^)(NSError *error)) errorBlock;
- (void) getCommentsFromPlace:(STPlace *) place
                 withStickers:(NSArray *) stickers
                   completion:(void (^)(NSArray *comments)) completionBlock
                        error:(void (^)(NSError *error)) errorBlock;


- (void) resolveUserById:(NSNumber *)userId
              importance:(STOverlordOperationImportance) importance
              requestNew:(BOOL) requestNew
              completion:(void (^)(STUser *place)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock;

- (void) resolveBoardCommentById:(NSNumber *) commentId
                      importance:(STOverlordOperationImportance) importance
                      requestNew:(BOOL) requestNew
                      completion:(void (^)(STBoardComment *place)) completionBlock
                           error:(void (^)(NSError *error)) errorBlock;
- (void) resolvePlaceById:(NSNumber *) placeId
               importance:(STOverlordOperationImportance) importance
               requestNew:(BOOL) requestNew
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock;
- (void) searchPlaceByLocation:(STLocation *) location
                    searchTerm:(NSString *) term
                    importance:(STOverlordOperationImportance) importance
                    requestNew:(BOOL) requestNew
                    completion:(void (^)(NSArray *places, NSUInteger page)) completionBlock
                         error:(void (^)(NSError *error)) errorBlock;
- (void) getCommentsFromPlace:(STPlace *) place
                 withStickers:(NSArray *) stickers
                   importance:(STOverlordOperationImportance) importance
                   requestNew:(BOOL) requestNew
                   completion:(void (^)(NSArray *comments)) completionBlock
                        error:(void (^)(NSError *error)) errorBlock;
- (void) updateCaches; //The Overlord will re-cache everything, he will use STOverlordImportanceLow to do this
- (void) deleteCaches; //If memory is low, call this. This may occur, because the overlord will try to cache everything it resolves
@end
