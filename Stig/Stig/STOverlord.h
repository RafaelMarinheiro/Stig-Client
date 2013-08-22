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
#import "STSticker.h"

typedef NSUInteger STOverlordToken;

@protocol STOverlord

@property (nonatomic, strong) STUser * user;
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

- (void) postCommentWithText: (NSString*) text
                 andStickers: (NSArray*) stickers
               toPlaceWithId: (NSNumber *) placeId
                  usingToken: (STOverlordToken) token
                  completion: (void (^)(STBoardComment * comment)) completionBlock
                       error: (void (^)(NSError *error)) errorBlock;

- (void) postCommentWithText: (NSString *) text
                 andStickers: (NSArray *) stickers
                   inReplyTo: (STBoardComment*) comment
                  usingToken: (STOverlordToken) token
                  completion: (void (^)(STBoardComment * comment)) completionBlock
                       error: (void (^)(NSError *error)) errorBlock;

#pragma mark - Raw Get methods

- (void) getCheckInHistoryFromUser:(STUser*) user
                        pageNumber: (NSUInteger) pageNumber
                        requestNew: (BOOL) requestNew
                        completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

- (void) getCommentsFromPlace: (STPlace *) place
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   requestNew: (BOOL) requestNew
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

- (void) getCommentsInReplyTo: (STBoardComment *) comment
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   requestNew: (BOOL) requestNew
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;


- (void) getPlacesWithSearchTerm: (NSString *) term
                      pageNumber: (NSUInteger) pageNumber
                      requestNew: (BOOL) requestNew
                      completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                           error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

#pragma mark - Simple Get methods

- (void) getCheckInHistoryFromUser:(STUser*) user
                        pageNumber: (NSUInteger) pageNumber
                        completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

- (void) getCommentsFromPlace: (STPlace *) place
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

- (void) getCommentsInReplyTo: (STBoardComment *) comment
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

- (void) getPlacesWithSearchTerm: (NSString *) term
                      pageNumber: (NSUInteger) pageNumber
                      completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                           error: (void (^) (NSError* error)) errorBlock DEPRECATED_ATTRIBUTE;

# pragma mark - Token Stuff


# pragma mark - -Token Requests

- (STOverlordToken) requestTokenForBoard: (STPlace *) place
                   filteringWithStickers:(NSArray *) stickers;

- (STOverlordToken) requestTokenForPlacesWithSearchTerm: (NSString *) term;

- (STOverlordToken) requestTokenForCheckInHistoryOfUser: (STUser *) user;

# pragma mark - -Token Queries

- (void) getCommentAndUserForToken: (STOverlordToken) token
                       andPosition: (NSUInteger) position
                        completion: (void (^) (STBoardComment * comment, STUser * user)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock;

- (void) getPlaceForToken: (STOverlordToken) token
              andPosition: (NSUInteger) position
               completion: (void (^) (STPlace * place)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock;

- (void) getCheckInHistoryPlaceForToken: (STOverlordToken) token
                            andPosition: (NSUInteger) position
                             completion: (void (^) (STPlace * place)) completionBlock
                                  error: (void (^) (NSError* error)) errorBlock;

# pragma mark - -Token counting

- (void) getNumberOfCommentsForToken: (STOverlordToken) token
                          completion: (void (^) (NSUInteger numberOfComments)) completionBlock
                               error: (void (^) (NSError* error)) errorBlock;

- (void) getNumberOfPlacesForToken: (STOverlordToken) token
                        completion: (void (^) (NSUInteger numberOfPlaces)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock;

- (void) getNumberOfCheckinsForToken: (STOverlordToken) token
                          completion: (void (^) (NSUInteger numberOfCheckins)) completionBlock
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
