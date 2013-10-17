//
//  STNetworkingOverlord.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STNetworkingOverlord.h"
#import "STNetworkManager.h"

@implementation STNetworkingOverlord{
    id<STOverlord> _apiConsumer;
    NSCache * _users;
    NSCache * _places;
    NSCache * _commentsByPlaces;
}


- (id) init{
    self = [super init];
    if(self){
        _apiConsumer = [STHiveCluster spawnAPIConsumer];
        _users = [[NSCache alloc] init];
        _places = [[NSCache alloc] init];
        _commentsByPlaces = [[NSCache alloc] init];
    }
    return self;
}


- (STUser *) user{
    return _apiConsumer.user;
}

- (void) setUser:(STUser *)user{
    _apiConsumer.user = user;
}

- (STLocation *) userLocation{
    return _apiConsumer.userLocation;
}

- (void) setUserLocation:(STLocation *)userLocation{
    _apiConsumer.userLocation = userLocation;
}

#pragma mark - Check-In methods

- (void) checkInPlace: (STPlace *) place
           completion: (void (^)(STUser * user, STPlace * place)) completionBlock
                error: (void (^) (NSError* error)) errorBlock{
    [_apiConsumer checkInPlace:place completion:completionBlock error:errorBlock];
}

#pragma mark - Like/Dislike

- (void) likeComment:(STBoardComment *)comment completion:(void (^)(STBoardComment *))completionBlock error:(void (^)(NSError *))errorBlock{
    [_apiConsumer likeComment:comment completion:completionBlock error:errorBlock];
}

- (void) dislikeComment:(STBoardComment *)comment completion:(void (^)(STBoardComment *))completionBlock error:(void (^)(NSError *))errorBlock{
    [_apiConsumer dislikeComment:comment completion:completionBlock error:errorBlock];
}

#pragma mark - Authentication methods


- (void) signInUserWithId: (NSNumber *) userId
             withPassword: (NSString *) password
               completion: (void (^)(STUser * user)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock{
    [_apiConsumer signInUserWithId:userId withPassword:password completion:completionBlock error:errorBlock];
}

- (void) authenticateUserOpeningUI: (BOOL) openUI
                        completion: (void (^)(STUser * user)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock{
    [_apiConsumer authenticateUserOpeningUI:openUI completion:completionBlock error:errorBlock];
}

- (void) signOutWithCompletion: (void (^)()) completionBlock
                         error: (void (^) (NSError* error)) errorBlock{
    [_apiConsumer signOutWithCompletion:completionBlock error:errorBlock];
}

#pragma mark - Raw Resolve methods


//User
- (void) resolveUserById:(NSNumber *)userId
              requestNew:(BOOL) requestNew
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock{
    STUser * user = nil;
    if(!requestNew){
        user = [_users objectForKey:userId];
        if(user){
            if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock((STUser *) user);
            });
            return;
        }
    }

    [_apiConsumer resolveUserById:userId completion:^(STUser *user) {
        [_users setObject:user forKey:user.userId];
        if(completionBlock) completionBlock(user);
    } error:errorBlock];
}

//Place
- (void) resolvePlaceById:(NSNumber *) placeId
               requestNew:(BOOL) requestNew
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock{
    STPlace * place = nil;
    if(!requestNew){
        place = [_places objectForKey:placeId];
        if(place){
            if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock((STPlace *) place);
            });
            return;
        }
    }
    
    [_apiConsumer resolvePlaceById:placeId completion:^(STPlace *place) {
        [_places setObject:place forKey:place.placeId];
        if(completionBlock) completionBlock(place);
    } error:errorBlock];
}

//Comment
- (void) resolveCommentById:(NSNumber *) commentId
                  fromPlace:(NSNumber *) placeId
                 requestNew:(BOOL) requestNew
                 completion:(void (^)(STBoardComment *comment)) completionBlock
                      error:(void (^)(NSError *error)) errorBlock{
    STBoardComment * comment = nil;
    if(!requestNew){
        NSCache * comments = [_commentsByPlaces objectForKey:placeId];
        if(comments){
            comment = [comments objectForKey:commentId];
            if(comment){
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                    completionBlock((STBoardComment *) comment);
                });
                return;
            }
        }
    }
    
    [_apiConsumer resolveCommentById:commentId fromPlace:placeId completion:^(STBoardComment *comment) {
        NSCache * board = [_commentsByPlaces objectForKey:placeId];
        if(!board){
            board = [[NSCache alloc]init];
            [_commentsByPlaces setObject:board forKey:placeId];
        }
        [board setObject:comment forKey:commentId];
        if(completionBlock) completionBlock((STBoardComment *) comment);
    } error:errorBlock];
}

#pragma mark - Simple Resolve Methods
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock{
    [self resolveUserById:userId requestNew:NO completion:completionBlock error:errorBlock];
}


- (void) resolvePlaceById:(NSNumber *) placeId
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock{
    [self resolvePlaceById:placeId requestNew:NO completion:completionBlock error:errorBlock];
}

- (void) resolveCommentById:(NSNumber *) commentId
                  fromPlace:(NSNumber *) placeId
                 completion:(void (^)(STBoardComment *place)) completionBlock
                      error:(void (^)(NSError *error)) errorBlock{
    [self resolveCommentById:commentId fromPlace:placeId requestNew:NO completion:completionBlock error:errorBlock];
}

#pragma mark - Token queries

- (void) getPlacesInPage: (NSUInteger) page
 filteringWithSearchTerm: (NSString *) term
              completion: (void (^) (NSArray * places, NSUInteger count, NSUInteger pageCount)) completionBlock
                   error: (void (^) (NSError * error)) errorBlock{
    [_apiConsumer getPlacesInPage:page filteringWithSearchTerm:term completion:^(NSArray *places, NSUInteger count, NSUInteger pageCount) {
        
        for(int i = 0; i < places.count; i++){
            STPlace * place = places[i];
            [_places setObject:place forKey:place.placeId];
        }
        if(completionBlock) completionBlock(places, count, pageCount);
    } error:errorBlock];
}

- (void) getCheckInHistoryPlacesInPage: (NSUInteger) page
                               forUser: (STUser *) user
                            completion: (void (^) (NSArray * places, NSArray * dates, NSUInteger count, NSUInteger pages)) completionBlock
                                 error: (void (^) (NSError* error)) errorBlock{

    [_apiConsumer getCheckInHistoryPlacesInPage:page forUser:user completion:^(NSArray *places, NSArray *dates, NSUInteger count, NSUInteger pages) {
        if(completionBlock) completionBlock(places, dates, count, pages);
    } error:errorBlock];
}

- (void) getCommentsInPage: (NSUInteger) page
                  ForPlace: (STPlace *) place
     filteringWithStickers: (NSArray *) stickers
                completion: (void (^) (NSArray * comments, NSUInteger count, NSUInteger pageCount)) completionBlock
                     error: (void (^) (NSError* error)) errorBlock{
    [_apiConsumer getCommentsInPage:page ForPlace:place filteringWithStickers:stickers completion:^(NSArray *comments, NSUInteger count, NSUInteger pageCount) {
        for(int i = 0; i < comments.count; i++){
            STBoardComment * comment = comments[i];
            NSCache * board = [_commentsByPlaces objectForKey:place.placeId];
            if(!board){
                board = [[NSCache alloc]init];
                [_commentsByPlaces setObject:board forKey:place.placeId];
            }
            [board setObject:comment forKey:comment.commentId];
        }
        if(completionBlock) completionBlock(comments, count, pageCount);
    } error:errorBlock];
}

#pragma mark - Insertion methods

- (void) postCommentWithText: (NSString*) text
                 andStickers: (NSArray*) stickers
               toPlaceWithId: (NSNumber *) placeId
                  usingToken: (STOverlordToken) token
                  completion: (void (^)(STBoardComment * comment)) completionBlock
                       error: (void (^)(NSError *error)) errorBlock{
    [_apiConsumer postCommentWithText:text andStickers:stickers toPlaceWithId:placeId completion:^(STBoardComment *comment) {
        NSCache * board = [_commentsByPlaces objectForKey:comment.placeId];
        if(!board){
            board = [[NSCache alloc]init];
            [_commentsByPlaces setObject:board forKey:comment.placeId];
        }
        [board setObject:comment forKey:comment.commentId];
        if(completionBlock) completionBlock(comment);
    } error:errorBlock];
}
@end
