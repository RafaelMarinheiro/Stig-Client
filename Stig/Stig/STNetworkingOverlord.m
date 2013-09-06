//
//  STNetworkingOverlord.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STNetworkingOverlord.h"
#import "STSafeMutableDictionary.h"
#import "AFNetworking.h"
#import "STBoardCommentQueryContext.h"
#import "STCheckInHistoryQueryContext.h"
#import "STPlacesQueryContext.h"
#import "STNetworkManager.h"
#import <FacebookSDK/FacebookSDK.h>


@implementation STNetworkingOverlord{
    AFHTTPClient * _client;
    NSUInteger _counter;
    NSCache * _users;
    NSCache * _places;
    NSCache * _commentsByPlaces;
    STNetworkManager * _manager;
    STSafeMutableDictionary * _tokenToBoardQuery;
    STSafeMutableDictionary * _tokenToCheckInQuery;
    STSafeMutableDictionary * _tokenToPlacesQuery;
    STUser * _user;
    STLocation *_userLocation;
    NSString * _fb_id;
    NSString * _fb_accesstoken;
    NSLock * _lock;
}


- (id) init{
    self = [super init];
    if(self){
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.stigapp.co/"]];
        _manager = [[STNetworkManager alloc] init];
        _manager.client = _client;
        _user = nil;
        _counter = 1;
        _lock = [[NSLock alloc] init];
        _users = [[NSCache alloc] init];
        _places = [[NSCache alloc] init];
        _commentsByPlaces = [[NSCache alloc] init];
        _tokenToBoardQuery = [[STSafeMutableDictionary alloc] init];
        _tokenToCheckInQuery = [[STSafeMutableDictionary alloc] init];
        _tokenToPlacesQuery = [[STSafeMutableDictionary alloc] init];
    }
    return self;
}


- (STUser *) user{
    return _user;
}

- (void) setUser:(STUser *)user{
    _user = user;
}

- (STLocation *) userLocation{
    return _userLocation;
}

- (void) setUserLocation:(STLocation *)userLocation{
    _userLocation = userLocation;
}

#pragma mark - Check-In methods

- (void) checkInPlace: (STPlace *) place
           completion: (void (^)(STUser * user, STPlace * place)) completionBlock
                error: (void (^) (NSError* error)) errorBlock{

    if(!self.user){
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock([NSError errorWithDomain:@"User is not logged in" code:42 userInfo:nil]);
        });
        return;
    }

    NSString * path = [[@"places/" stringByAppendingString:[[place placeId] stringValue]] stringByAppendingString:@"/checkin/"];

    [_client postPath:path parameters:nil
              success:^(AFHTTPRequestOperation *operation, id data) {
                  if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^{
                      completionBlock(self.user, place);
                  });
              } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                  if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                      errorBlock(error);
                  });
              }];
}

#pragma mark - Like/Dislike

- (void) likeComment:(STBoardComment *)comment completion:(void (^)(STBoardComment *))completionBlock error:(void (^)(NSError *))errorBlock{

    if(!self.user){
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock([NSError errorWithDomain:@"User is not logged in" code:42 userInfo:nil]);
        });
        return;
    }

    NSString * path = [[[[@"places/" stringByAppendingString:[[comment placeId] stringValue]] stringByAppendingString:@"/comments/"] stringByAppendingString:[[comment commentId] stringValue]]stringByAppendingString:@"/like/"];

    [_client postPath:path parameters:nil
              success:^(AFHTTPRequestOperation *operation, id data) {
                  if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^{
                      completionBlock(comment);
                  });
              } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                  if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                      errorBlock(error);
                  });
              }];
}

- (void) dislikeComment:(STBoardComment *)comment completion:(void (^)(STBoardComment *))completionBlock error:(void (^)(NSError *))errorBlock{

    if(!self.user){
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
            errorBlock([NSError errorWithDomain:@"User is not logged in" code:42 userInfo:nil]);
        });
        return;
    }

    NSString * path = [[[[@"places/" stringByAppendingString:[[comment placeId] stringValue]] stringByAppendingString:@"/comments/"] stringByAppendingString:[[comment commentId] stringValue]]stringByAppendingString:@"/dislike/"];

    [_client postPath:path parameters:nil
              success:^(AFHTTPRequestOperation *operation, id data) {
                  if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^{
                      completionBlock(comment);
                  });
              } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                  if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                      errorBlock(error);
                  });
              }];
}

#pragma mark - Authentication methods


- (void) signInUserWithId: (NSNumber *) userId
             withPassword: (NSString *) password
               completion: (void (^)(STUser * user)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock{
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Not implemented" code:43 userInfo:nil]);
    });
    
}

- (void) authenticateUserOpeningUI: (BOOL) openUI
                        completion: (void (^)(STUser * user)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock{
    if(_user){
        if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^{
            completionBlock(_user);
        });
        return;
    }

    typedef void(^STFacebookBlock)(FBRequestConnection *connection,
                                   NSDictionary<FBGraphUser> *user,
                                   NSError *error);

    STFacebookBlock umnomebom = ^(FBRequestConnection *connection,
                                          NSDictionary<FBGraphUser> *user,
                                          NSError *error) {
        if(!error){
            _user = nil;
            _fb_id = [user id];
            _fb_accesstoken = [[FBSession.activeSession accessTokenData] accessToken];

            [_client setAuthorizationHeaderWithUsername:_fb_id password:_fb_accesstoken];

            NSString * path = @"/users/me/";
            [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, NSData * data) {
                NSError * error;
                id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                _user = nil;

                if(json){
                    NSDictionary * dic = json;
                    _user = [STUser userFromServerJSONData:dic];
                    if(_user){
                        [_users setObject:_user forKey:_user.userId];
                        [_client setAuthorizationHeaderWithUsername:_fb_id password:_fb_accesstoken];
                        if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                            completionBlock(_user);
                        });
                        return;
                    }
                }

                if(!_user){
                    [_client clearAuthorizationHeader];
                    error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
                    if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                        errorBlock(error);
                    });
                    return;
                }
            } error:^(AFHTTPRequestOperation *operation, NSError *error) {
                [_client clearAuthorizationHeader];
                if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                    errorBlock(error);
                });
            }];
        }
        else{
            if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                errorBlock(error);
            });
        }
    };

    if(openUI){

        if(![FBSession.activeSession isOpen]){
            [FBSession.activeSession openWithBehavior:FBSessionLoginBehaviorUseSystemAccountIfPresent
                                    completionHandler:^(FBSession *session,
                                                        FBSessionState status,
                                                        NSError *error) {
                                        if ([FBSession.activeSession isOpen]) {
                                            [[FBRequest requestForMe] startWithCompletionHandler:
                                             umnomebom];
                                        }else{
                                            if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                                                errorBlock(error);
                                            });
                                        }
                                    }];
        } else{
            [[FBRequest requestForMe] startWithCompletionHandler:
             umnomebom];
        }
    } else{
        if(![FBSession.activeSession isOpen]){
            [FBSession openActiveSessionWithAllowLoginUI:NO];
        }
        if ([FBSession.activeSession isOpen]) {
            [[FBRequest requestForMe] startWithCompletionHandler:
             umnomebom];
        }
    }
}

- (void) signOutWithCompletion: (void (^)()) completionBlock
                         error: (void (^) (NSError* error)) errorBlock{
    _user = nil;
    dispatch_async(dispatch_get_main_queue(), ^(){
        completionBlock();
    });
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
            dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock((STUser *) user);
            });
            return;
        }
    }

    NSString * path = [[@"users/" stringByAppendingString:[userId stringValue]] stringByAppendingString:@"/"];

    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        STUser * user = nil;
        
        if(json){
            NSDictionary * dic = json;
            user = [STUser userFromServerJSONData:dic];
            if(user){
                [_users setObject:user forKey:user.userId];
                dispatch_async(dispatch_get_main_queue(), ^(){
                    completionBlock((STUser *) user);
                });
                return;
            }
        }
        
        if(!user){
            error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
            if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                errorBlock(error);
            });
            return;
        }
    }error: ^(AFHTTPRequestOperation * operation, NSError *error){
        NSError * nerror;
        if([[operation response] statusCode]){
            nerror = [[NSError alloc] initWithDomain:@"User not found" code:404 userInfo:nil];
        } else{
            nerror = [[NSError alloc] initWithDomain:@"Unknown error" code:500 userInfo:
                       nil];
        }
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock(nerror);
        });
        return;
    }];
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
            dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock((STPlace *) place);
            });
            return;
        }
    }
    
    NSString * path = [[@"places/" stringByAppendingString:[placeId stringValue]] stringByAppendingString:@"/"];
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STPlace * place = nil;
         
         if(json){
             NSDictionary * dic = json;
             place = [STPlace placeFromServerJSONData:dic];
             if(place){
                 [_places setObject:place forKey:place.placeId];
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     completionBlock((STPlace *) place);
                 });
                 return;
             }
         }
         
         if(!place){
             error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
             if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                 errorBlock(error);
             });
             return;
         }
     }error: ^(AFHTTPRequestOperation * operation, NSError *error){
         NSError * nerror;
         if([[operation response] statusCode]){
             nerror = [[NSError alloc] initWithDomain:@"Place not found" code:404 userInfo:nil];
         } else{
             nerror = [[NSError alloc] initWithDomain:@"Unknown error" code:500 userInfo:
                       nil];
         }
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(nerror);
         });
         return;
     }];
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
                dispatch_async(dispatch_get_main_queue(), ^(){
                    completionBlock((STBoardComment *) comment);
                });
                return;
            }
        }
    }
    
    NSString * path = [[[[@"places/" stringByAppendingString:[placeId stringValue]] stringByAppendingString:@"/comments/"] stringByAppendingString:[commentId stringValue]] stringByAppendingString:@"/"];
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STBoardComment * comment = nil;
         
         if(json){
             NSDictionary * dic = json;
             comment = [STBoardComment boardCommentFromServerJSONData:dic];
             if(comment){
                 NSCache * board = [_commentsByPlaces objectForKey:placeId];
                 if(!board){
                     board = [[NSCache alloc]init];
                     [_commentsByPlaces setObject:board forKey:placeId];
                 }
                 [board setObject:comment forKey:commentId];
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     completionBlock((STBoardComment *) comment);
                 });
                 return;
             }
         }
         
         if(!comment){
             error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
             if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                 errorBlock(error);
             });
             return;
         }
     }error: ^(AFHTTPRequestOperation * operation, NSError *error){
         NSError * nerror;
         if([[operation response] statusCode]){
             nerror = [[NSError alloc] initWithDomain:@"Comment not found" code:404 userInfo:nil];
         } else{
             nerror = [[NSError alloc] initWithDomain:@"Unknown error" code:500 userInfo:
                       nil];
         }
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(nerror);
         });
         return;
     }];
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

#pragma mark - Token requests
- (STOverlordToken) requestTokenForBoard: (STPlace *) place
                   filteringWithStickers:(NSArray *) stickers{
    NSUInteger num = 0;
    [_lock lock];
    num = _counter;
    _counter++;
    [_lock unlock];
    
    STBoardCommentQueryContext * context = [[STBoardCommentQueryContext alloc] initWithPlace:place andStickers:stickers];
    
    [_tokenToBoardQuery setObject:context forKey:@(num)];
    
    return num;
}

- (STOverlordToken) requestTokenForPlacesWithSearchTerm: (NSString *) term{
    NSUInteger num = 0;
    [_lock lock];
        num = _counter;
        _counter++;
    [_lock unlock];
    
    STPlacesQueryContext * context = [[STPlacesQueryContext alloc] initWithQueryString:[term stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [_tokenToPlacesQuery setObject:context forKey:@(num)];
    
    return num;
}

- (STOverlordToken) requestTokenForCheckInHistoryOfUser: (STUser *) user{
    NSUInteger num = 0;
    [_lock lock];
        num = _counter;
        _counter++;
    [_lock unlock];
    
    STCheckInHistoryQueryContext * context = [[STCheckInHistoryQueryContext alloc] initWithUser:user];
    [_tokenToCheckInQuery setObject:context forKey:@(num)];
    
    return num;
}

#pragma mark - Token queries

- (void) getPlaceForToken: (STOverlordToken) token
              andPosition: (NSUInteger) position
               completion: (void (^) (STPlace * place)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock{
    STPlacesQueryContext * context = [_tokenToPlacesQuery objectForKey:@(token)];
    if(context == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
        return;
    }
    
    NSNumber * placeId = [[context cache] objectForKey:@(position)];
    
    if(placeId){
        STPlace * place = [_places objectForKey:placeId];
        if(place){
            dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock(place);
            });
            return;
        }
    }

    NSNumber * page = @((position/10) + 1);
    NSNumber * baseNumber = @(([page unsignedIntegerValue]-1)*10);
    
    NSString * path = nil;
    if(context.queryString){
        path = [[[@"places/?page=" stringByAppendingString:[page stringValue]] stringByAppendingString: @"&q="] stringByAppendingString:context.queryString];
    } else{
        path = [@"places/?page=" stringByAppendingString:[page stringValue]];
    }
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STPlace * resultPlace = nil;
         
         if(json){
             NSDictionary * dic = json;
             NSNumber * count = dic[@"count"];
             [context.cache setObject:count forKey:@(-1)];
//             NSLog(@"%@ objects found", count);
             NSArray * result = dic[@"results"];
             for(int i = 0; i < result.count; i++){
                 STPlace * place = [STPlace placeFromServerJSONData:result[i]];
                 if(place){
                     [_places setObject:place forKey:place.placeId];
                     NSUInteger currentPosition = i+[baseNumber unsignedIntegerValue];
                     [context.cache setObject:place.placeId forKey:(@(currentPosition))];
//                     NSLog(@"Cached %@ in position %d for token %d", place, currentPosition, token);
                     if(position == currentPosition){
                         resultPlace = place;
                     }
                 }
             }

             if (resultPlace) {
                 dispatch_async(dispatch_get_main_queue(), ^(){
                     completionBlock(resultPlace);
                 });
             } else{
                 error = [[NSError alloc] initWithDomain:@"Place not found" code:404 userInfo:nil];
                 if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                     errorBlock(error);
                 });
             }
             return;
         }
         
         error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(error);
         });
     }error: ^(AFHTTPRequestOperation * operation, NSError *error){
         NSError * nerror;
         if([[operation response] statusCode]){
             nerror = [[NSError alloc] initWithDomain:@"Page does not exist" code:404 userInfo:nil];
         } else{
             nerror = [[NSError alloc] initWithDomain:@"Unknown error" code:500 userInfo:
                       nil];
         }
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(nerror);
         });
         return;
     }];
}

- (void) getCheckInHistoryPlaceForToken: (STOverlordToken) token
                            andPosition: (NSUInteger) position
                             completion: (void (^) (STPlace * place)) completionBlock
                                  error: (void (^) (NSError* error)) errorBlock{
    STCheckInHistoryQueryContext * context = [_tokenToCheckInQuery objectForKey:@(token)];
    if(context == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
        return;
    }
    
    NSNumber * placeId = [[context cache] objectForKey:@(position)];
    
    if(placeId){
        [self resolvePlaceById:placeId completion:completionBlock error:errorBlock];
        return;
    }
    
    NSNumber * page = @((position/10) + 1);
    NSNumber * baseNumber = @(([page unsignedIntegerValue]-1)*10);
    
    NSString * path = nil;
    path = [[[[@"users/" stringByAppendingString:[[context.user userId] stringValue]] stringByAppendingString:@"/checkins/"] stringByAppendingString:@"?page="] stringByAppendingString:[page stringValue]];
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         NSNumber * resultPlaceId = nil;
         
         if(json){
             NSDictionary * dic = json;
             NSNumber * count = dic[@"count"];
             [context.cache setObject:count forKey:@(-1)];
             NSLog(@"%@ objects found", count);
             NSArray * result = dic[@"results"];
             for(int i = 0; i < result.count; i++){
                 NSNumber * placeId = result[i][@"place"];
                 if(placeId){
                     NSUInteger currentPosition = i+[baseNumber unsignedIntegerValue];
                     [context.cache setObject:placeId forKey:(@(currentPosition))];
                     NSLog(@"Cached place ID %@ in position %d for token %d", placeId, currentPosition, token);
                     if(position == currentPosition){
                         resultPlaceId = placeId;
                     }
                 }
             }
             
             if (resultPlaceId) {
                 [self resolvePlaceById:resultPlaceId completion:completionBlock error:errorBlock];
             } else{
                 error = [[NSError alloc] initWithDomain:@"Place not found" code:404 userInfo:nil];
                 if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                     errorBlock(error);
                 });
             }
             return;
         }
         
         error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(error);
         });
     } error: ^(AFHTTPRequestOperation * operation, NSError *error){
         NSError * nerror;
         if([[operation response] statusCode]){
             nerror = [[NSError alloc] initWithDomain:@"Page does not exist" code:404 userInfo:nil];
         } else{
             nerror = [[NSError alloc] initWithDomain:@"Unknown error" code:500 userInfo:
                       nil];
         }
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(nerror);
         });
         return;
     }];
}

- (void) getCommentAndUserForToken: (STOverlordToken) token
                       andPosition: (NSUInteger) position
                        completion: (void (^) (STBoardComment * comment, STUser * user)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock{
    STBoardCommentQueryContext * context = [_tokenToBoardQuery objectForKey:@(token)];
    if(context == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
        return;
    }
    
    NSNumber * commentId = [[context cache] objectForKey:@(position)];
    
    if(commentId){
        NSCache * comments = [_commentsByPlaces objectForKey:context.place.placeId];
        if(comments){
            STBoardComment * comment = [comments objectForKey:commentId];
            if(comment){
                [self resolveUserById:comment.userId completion:^(STUser *user) {
                    completionBlock(comment, user);
                } error:errorBlock];
                return;
            }
        }
    }
    
    NSNumber * page = @((position/10) + 1);
    NSNumber * baseNumber = @(([page unsignedIntegerValue]-1)*10);
    
    NSString * path = nil;
    if(context.stickers){
        if([context.stickers count] == 0){
            path = [[[@"places/" stringByAppendingString:[context.place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[page stringValue]];
        } else{
            path = [[[[[@"places/" stringByAppendingString:[context.place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[page stringValue]] stringByAppendingString:@"&filter="] stringByAppendingString:[@([STSticker stickersServerQueryCodeFromArray:context.stickers]) stringValue]];
        }
    } else{
        path = [[[@"places/" stringByAppendingString:[context.place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[page stringValue]];
    }

    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STBoardComment * resultComment = nil;
         
         if(json){
             NSDictionary * dic = json;
             NSNumber * count = dic[@"count"];
             [context.cache setObject:count forKey:@(-1)];
//             NSLog(@"%@ objects found", count);
             NSArray * result = dic[@"results"];
             
             NSCache * board = [_commentsByPlaces objectForKey:context.place.placeId];
             if(!board){
                 board = [[NSCache alloc]init];
                 [_commentsByPlaces setObject:board forKey:context.place.placeId];
             }
             
             for(int i = 0; i < result.count; i++){
                 STBoardComment * comment = [STBoardComment boardCommentFromServerJSONData:result[i]];
                 if(comment){
                     
                     [board setObject:comment forKey:comment.commentId];
                     
                     NSUInteger currentPosition = i+[baseNumber unsignedIntegerValue];
                     [context.cache setObject:comment.commentId forKey:(@(currentPosition))];
                     
//                     NSLog(@"Cached %@ in position %d for token %d", comment, currentPosition, token);
                     if(position == currentPosition){
                         resultComment = comment;
                     }
                 }
             }
             
             if (resultComment) {
                 [self resolveUserById:[resultComment userId] completion:^(STUser *user) {
                     completionBlock(resultComment, user);
                 } error:errorBlock];
             } else{
                 error = [[NSError alloc] initWithDomain:@"Comment not found" code:404 userInfo:nil];
                 if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                     errorBlock(error);
                 });
             }
             return;
         }
         
         error = [[NSError alloc] initWithDomain:@"Invalid JSON" code:404 userInfo:nil];
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(error);
         });
     }error: ^(AFHTTPRequestOperation * operation, NSError *error){
         NSError * nerror;
         if([[operation response] statusCode]){
             nerror = [[NSError alloc] initWithDomain:@"Page does not exist" code:404 userInfo:nil];
         } else{
             nerror = [[NSError alloc] initWithDomain:@"Unknown error" code:500 userInfo:
                       nil];
         }
         if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock(nerror);
         });
         return;
     }];
}


#pragma mark - Token counting

- (void) getNumberOfCommentsForToken: (STOverlordToken) token
                          completion: (void (^) (NSUInteger numberOfComments)) completionBlock
                               error: (void (^) (NSError* error)) errorBlock{
    
    STBoardCommentQueryContext * context = [_tokenToBoardQuery objectForKey:@(token)];
    
    if(context){
        [self getCommentAndUserForToken:token andPosition:0 completion:^(STBoardComment *comment, STUser *user) {
            completionBlock([[context.cache objectForKey:@(-1)] unsignedIntegerValue]);
        } error:^(NSError* error){
            NSNumber *size = [context.cache objectForKey:@(-1)];
            if(size){
                completionBlock([size unsignedIntegerValue]);
            } else{
                errorBlock(error);
            }
        }];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
    }
}

- (void) getNumberOfPlacesForToken: (STOverlordToken) token
                        completion: (void (^) (NSUInteger numberOfPlaces)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock{
    
    STPlacesQueryContext * context = [_tokenToPlacesQuery objectForKey:@(token)];
    if(context){
        [self getPlaceForToken:token andPosition:0 completion:^(STPlace * place) {
            completionBlock([[context.cache objectForKey:@(-1)] unsignedIntegerValue]);
        } error:^(NSError* error){
            NSNumber * size = [context.cache objectForKey:@(-1)];
            if(size){
                completionBlock([size unsignedIntegerValue]);
            } else{
                errorBlock(error);
            }
        }];
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
    }
}

- (void) getNumberOfCheckinsForToken: (STOverlordToken) token
                          completion: (void (^) (NSUInteger numberOfCheckins)) completionBlock
                               error: (void (^) (NSError* error)) errorBlock{
    STCheckInHistoryQueryContext * context = [_tokenToCheckInQuery objectForKey:@(token)];
    if(context){
        [self getCheckInHistoryPlaceForToken:token andPosition:0 completion:^(STPlace *place) {
            completionBlock([[context.cache objectForKey:@(-1)] unsignedIntegerValue]);
        } error:^(NSError* error){
            NSNumber * size = [context.cache objectForKey:@(-1)];
            if(size){
                completionBlock([size unsignedIntegerValue]);
            } else{
                errorBlock(error);
            }
        }];
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
    }
}

#pragma mark - Insertion methods

- (void) postCommentWithText: (NSString*) text
                 andStickers: (NSArray*) stickers
               toPlaceWithId: (NSNumber *) placeId
                  usingToken: (STOverlordToken) token
                  completion: (void (^)(STBoardComment * comment)) completionBlock
                       error: (void (^)(NSError *error)) errorBlock{
    if(_user == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User is not logged in" code:41 userInfo:nil]);
        });
        return;
    }
    
    STBoardCommentQueryContext * context = [_tokenToBoardQuery objectForKey:@(token)];
    if(!context){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:41 userInfo:nil]);
        });
        return;
    }
    
    NSString * path = [[@"places/" stringByAppendingString:[placeId stringValue]] stringByAppendingString:@"/comments/"];


    [_client postPath:path parameters:[NSDictionary dictionaryWithObjectsAndKeys:text, @"content", @([STSticker stickersServeCodeFromArray:stickers]), @"stickers", nil]
             success:^(AFHTTPRequestOperation *operation, id data) {
                 NSError * error;
                 id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                 STBoardComment * resultComment = nil;

                 if(json){
                     resultComment = [STBoardComment boardCommentFromServerJSONData:json];

                     NSCache * board = [_commentsByPlaces objectForKey:context.place.placeId];
                     if(!board){
                         board = [[NSCache alloc]init];
                         [_commentsByPlaces setObject:board forKey:context.place.placeId];
                     }

                     resultComment = [STBoardComment boardCommentFromServerJSONData:json];

                     if(resultComment){
                         [board setObject:resultComment forKey:resultComment.commentId];

                         NSNumber * size = [context.cache objectForKey:@(-1)];

                         NSUInteger currentPosition = 1+[size unsignedIntegerValue];

                         [context.cache setObject:resultComment.commentId forKey:@(currentPosition)];

                         [context.cache setObject:@(-1) forKey:@(currentPosition)];
//                         NSLog(@"Cached %@ in position %d for token %d", resultComment, currentPosition, token);
                     }
                 }

                 if (resultComment) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                         completionBlock(resultComment);
                     });
                 } else{
                     error = [[NSError alloc] initWithDomain:@"Comment not found" code:404 userInfo:nil];
                     if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                         errorBlock(error);
                     });
                 }
                 return;
             } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                 if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                     errorBlock(error);
                 });
             }];
}
@end
