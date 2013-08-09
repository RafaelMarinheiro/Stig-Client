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


@protocol STOverlord

@property (nonatomic, strong, readonly) STUser * user;
@property (nonatomic, strong) STLocation *userLocation;


#pragma mark - Authentication methods
- (void) signInUserWithId: (NSNumber *) userId
             withPassword: (NSString *) password
               completion: (void (^)(STUser * user)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock;

- (void) authenticateUserWithId: (NSNumber *) userId
                   withPassword: (NSString *) password
                     completion: (void (^)(STUser * user)) completionBlock
                          error: (void (^) (NSError* error)) errorBlock;

- (void) signOutUser: (NSNumber *) userId
          completion: (void (^)()) completionBlock
               error: (void (^) (NSError* error)) errorBlock;

#pragma mark - Check-In methods

- (void) checkInPlace: (STPlace *) place
           completion: (void (^)(STUser * user, STPlace * place)) completionBlock
                error: (void (^) (NSError* error)) errorBlock;


#pragma mark - Raw Resolve methods

// User
- (void) resolveUserById:(NSNumber *)userId
              requestNew:(BOOL) requestNew
              completion:(void (^)(STUser *place)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock;

//Place
- (void) resolvePlaceById:(NSNumber *) placeId
               requestNew:(BOOL) requestNew
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock;

//Comment
- (void) resolveCommentById:(NSNumber *) commentId
                       fromPlace:(NSNumber *) placeId
                      requestNew:(BOOL) requestNew
                      completion:(void (^)(STBoardComment *place)) completionBlock
                           error:(void (^)(NSError *error)) errorBlock;


#pragma mark - Simple Resolve Methods
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock;


- (void) resolvePlaceById:(NSNumber *) placeId
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock;

- (void) resolveCommentById:(NSNumber *) commentId
                       fromPlace:(NSNumber *) placeId
                    completion:(void (^)(STBoardComment *place)) completionBlock
                        error:(void (^)(NSError *error)) errorBlock;

#pragma mark - Insertion methods

- (void) postComment: (STBoardComment*) comment
       toPlaceWithId: (NSNumber *) placeId
          completion: (void (^)(STBoardComment * comment)) completionBlock
               error: (void (^)(NSError *error)) errorBlock;

- (void) postComment: (STBoardComment*) comment
           inReplyTo: (STBoardComment*) comment
          completion: (void (^)(STBoardComment * comment)) completionBlock
               error: (void (^)(NSError *error)) errorBlock;

#pragma mark - Raw Get methods

- (void) getCheckInHistoryFromUser:(STUser*) user
                        pageNumber: (NSUInteger) pageNumber
                        requestNew: (BOOL) requestNew
                        completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock;

- (void) getCommentsFromPlace: (STPlace *) place
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   requestNew: (BOOL) requestNew
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock;

- (void) getCommentsInReplyTo: (STBoardComment *) comment
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   requestNew: (BOOL) requestNew
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock;


- (void) getPlacesWithSearchTerm: (NSString *) term
                      pageNumber: (NSUInteger) pageNumber
                      requestNew: (BOOL) requestNew
                      completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                           error: (void (^) (NSError* error)) errorBlock;

#pragma mark - Simple Get methods

- (void) getCheckInHistoryFromUser:(STUser*) user
                        pageNumber: (NSUInteger) pageNumber
                        completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock;

- (void) getCommentsFromPlace: (STPlace *) place
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock;

- (void) getCommentsInReplyTo: (STBoardComment *) comment
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock;

- (void) getPlacesWithSearchTerm: (NSString *) term
                      pageNumber: (NSUInteger) pageNumber
                      completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                           error: (void (^) (NSError* error)) errorBlock;


@end


typedef enum{
    STOverlordTypeNetworked,
    STOverlordTypeLocalJson,
    STOverlordTypeNumbers
} STOverlordType;

@interface STHiveCluster : NSObject

+ (id<STOverlord>) spawnOverlord;
+ (void) setDefaultOverlordType: (STOverlordType) type;
+ (id<STOverlord>) spawnOverlordWithType:(STOverlordType) type;

@end
