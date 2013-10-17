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

#pragma mark - Check In
- (void) checkInPlace: (STPlace *) place
           completion: (void (^)(STUser * user, STPlace * place)) completionBlock
                error: (void (^) (NSError* error)) errorBlock;

#pragma mark - Like/Dislike
- (void) likeComment:(STBoardComment *)comment completion:(void (^)(STBoardComment *))completionBlock error:(void (^)(NSError *))errorBlock;

- (void) dislikeComment:(STBoardComment *)comment completion:(void (^)(STBoardComment *))completionBlock error:(void (^)(NSError *))errorBlock;

#pragma mark - Authentication
- (void) signInUserWithId: (NSNumber *) userId
             withPassword: (NSString *) password
               completion: (void (^)(STUser * user)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock;

- (void) authenticateUserOpeningUI: (BOOL) openUI
                        completion: (void (^)(STUser * user)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock;

- (void) signOutWithCompletion: (void (^)()) completionBlock
                         error: (void (^) (NSError* error)) errorBlock;

#pragma mark - Fetch Entities
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock;

- (void) resolvePlaceById:(NSNumber *) placeId
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock;

- (void) resolveCommentById:(NSNumber *) commentId
                  fromPlace:(NSNumber *) placeId
                 completion:(void (^)(STBoardComment *comment)) completionBlock
                      error:(void (^)(NSError *error)) errorBlock;

#pragma mark - Fetch lists
- (void) getPlacesInPage: (NSUInteger) page
 filteringWithSearchTerm: (NSString *) term
              completion: (void (^) (NSArray * places, NSUInteger count, NSUInteger pageCount)) completionBlock
                   error: (void (^) (NSError * error)) errorBlock;

- (void) getCheckInHistoryPlacesInPage: (NSUInteger) page
                               forUser: (STUser *) user
                            completion: (void (^) (NSArray * places, NSArray * dates, NSUInteger count, NSUInteger pages)) completionBlock
                                 error: (void (^) (NSError* error)) errorBlock;

- (void) getCommentsInPage: (NSUInteger) page
                  ForPlace: (STPlace *) place
     filteringWithStickers: (NSArray *) stickers
                completion: (void (^) (NSArray * comments, NSUInteger count, NSUInteger pageCount)) completionBlock
                     error: (void (^) (NSError* error)) errorBlock;

#pragma mark - Post comments
- (void) postCommentWithText: (NSString*) text
                 andStickers: (NSArray*) stickers
               toPlaceWithId: (NSNumber *) placeId
                  completion: (void (^)(STBoardComment * comment)) completionBlock
                       error: (void (^)(NSError *error)) errorBlock;
@end


typedef enum{
    STOverlordTypeSimple,
    STOverlordTypeNetworked,
    STOverlordTypeLocalJson,
    STOverlordTypeNumbers
} STOverlordType;

@interface STHiveCluster : NSObject

+ (id<STOverlord>) spawnAPIConsumer;
+ (id<STOverlord>) spawnOverlord;
+ (void) setDefaultOverlordType: (STOverlordType) type;
+ (id<STOverlord>) spawnOverlordWithType:(STOverlordType) type;

@end
