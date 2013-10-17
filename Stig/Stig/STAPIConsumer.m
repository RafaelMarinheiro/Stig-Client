//
//  STSimpleOverlord.m
//  Stig
//
//  Created by Camila Marinheiro on 16/10/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STAPIConsumer.h"
#import "STNetworkManager.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation STAPIConsumer{
    AFHTTPClient * _client;
    STNetworkManager * _manager;
    STUser * _user;
    STLocation *_userLocation;
    NSString * _fb_id;
    NSString * _fb_accesstoken;
}


- (id) init{
    self = [super init];
    if(self){
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.stigapp.co/"]];
        _manager = [[STNetworkManager alloc] init];
        _manager.client = _client;
        _user = nil;
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
    if(_userLocation){
        NSString * content = [NSString stringWithFormat:@"geo:%f,%f", [_userLocation.longitude floatValue], [_userLocation.latitude floatValue]];
        [_client setDefaultHeader:@"Geolocation" value:content];
    }
    NSLog(@"%@", userLocation);
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
    
    NSString * path = @"users/";
    [_client clearAuthorizationHeader];
    [_client postPath:path parameters:[NSDictionary dictionaryWithObjectsAndKeys:_fb_id, @"fb_id", _fb_accesstoken, @"access_token", nil]
              success:^(AFHTTPRequestOperation *operation, id data) {
                  NSError * error;
                  id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                  STUser * resultUser = nil;
                  
                  if(json){
                      resultUser = [STUser userFromServerJSONData:json];
                      
                      if(resultUser){
                          _user = resultUser;
                          [_client setAuthorizationHeaderWithUsername:_fb_id password:_fb_accesstoken];
                      }
                  }
                  
                  if (resultUser) {
                      if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^{
                          completionBlock(resultUser);
                      });
                  } else{
                      error = [[NSError alloc] initWithDomain:@"User format is not accepted" code:404 userInfo:nil];
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
    [_client clearAuthorizationHeader];
    if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
        completionBlock();
    });
}

#pragma mark - Raw Resolve methods


//User
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock{
    NSString * path = [[@"users/" stringByAppendingString:[userId stringValue]] stringByAppendingString:@"/"];
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        STUser * user = nil;
        
        if(json){
            NSDictionary * dic = json;
            user = [STUser userFromServerJSONData:dic];
            if(user){
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
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
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock{
    NSString * path = [[@"places/" stringByAppendingString:[placeId stringValue]] stringByAppendingString:@"/"];
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        STPlace * place = nil;
        
        if(json){
            NSDictionary * dic = json;
            place = [STPlace placeFromServerJSONData:dic];
            if(place){
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
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
                 completion:(void (^)(STBoardComment *comment)) completionBlock
                      error:(void (^)(NSError *error)) errorBlock{
    
    NSString * path = [[[[@"places/" stringByAppendingString:[placeId stringValue]] stringByAppendingString:@"/comments/"] stringByAppendingString:[commentId stringValue]] stringByAppendingString:@"/"];
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        STBoardComment * comment = nil;
        
        if(json){
            NSDictionary * dic = json;
            comment = [STBoardComment boardCommentFromServerJSONData:dic];
            if(comment){
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
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

- (void) getPlacesInPage: (NSUInteger) page
 filteringWithSearchTerm: (NSString *) term
              completion: (void (^) (NSArray * places, NSUInteger count, NSUInteger pageCount)) completionBlock
                   error: (void (^) (NSError * error)) errorBlock
{
    NSNumber * pageN = @(page);
    NSString * path = nil;
    if(term){
        path = [[[@"places/?page=" stringByAppendingString:[pageN stringValue]] stringByAppendingString: @"&q="] stringByAppendingString:term];
    } else{
        path = [@"places/?page=" stringByAppendingString:[pageN stringValue]];
    }
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        if(json){
            NSDictionary * dic = json;
            NSNumber * count = dic[@"count"];
            NSUInteger pageCount = ([count unsignedIntegerValue] + 9)/10;
            NSArray * result = dic[@"results"];
            NSMutableArray * results = [NSMutableArray arrayWithCapacity:result.count];
            BOOL err = NO;
            for(int i = 0; i < result.count; i++){
                STPlace * place = [STPlace placeFromServerJSONData:result[i]];
                if(place){
                    results[i] = place;
                } else{
                    err = YES;
                }
            }
            
            if (!err) {
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                    completionBlock(results, [count unsignedIntegerValue], pageCount);
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
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock(error);
        });
        return;
    }];

}

- (void) getCheckInHistoryPlacesInPage: (NSUInteger) page
                                forUser: (STUser *) user
                             completion: (void (^) (NSArray * places, NSArray * dates, NSUInteger count, NSUInteger pages)) completionBlock
                                  error: (void (^) (NSError* error)) errorBlock{    
    NSNumber * pageN = @(page);
    
    NSString * path = nil;
    path = [[[[@"users/" stringByAppendingString:[[user userId] stringValue]] stringByAppendingString:@"/checkins/"] stringByAppendingString:@"?page="] stringByAppendingString:[pageN stringValue]];
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(json){
            NSDictionary * dic = json;
            NSNumber * count = dic[@"count"];
            NSUInteger pageCount = ([count unsignedIntegerValue] + 9)/10;
            NSArray * result = dic[@"results"];
            NSMutableArray * places = [NSMutableArray arrayWithCapacity:result.count];
            NSMutableArray * dates = nil;
            
            BOOL err = NO;
            for(int i = 0; i < result.count; i++){
                NSNumber * placeId = result[i][@"place"];
                if(placeId){
                    places[i] = placeId;
                } else{
                    err = YES;
                }
            }
            
            if (!err) {
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                    completionBlock(places, dates, [count unsignedIntegerValue], pageCount);
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
    } error: ^(AFHTTPRequestOperation * operation, NSError *error){
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock(error);
        });
        return;
    }];
}

- (void) getCommentsInPage: (NSUInteger) page
                  ForPlace: (STPlace *) place
     filteringWithStickers: (NSArray *) stickers
                completion: (void (^) (NSArray * comments, NSUInteger count, NSUInteger pageCount)) completionBlock
                     error: (void (^) (NSError* error)) errorBlock{
        
    NSNumber * pageN = @(page);
    
    NSString * path = nil;
    if(stickers){
        if([stickers count] == 0){
            path = [[[@"places/" stringByAppendingString:[place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[pageN stringValue]];
        } else{
            path = [[[[[@"places/" stringByAppendingString:[place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[pageN stringValue]] stringByAppendingString:@"&filter="] stringByAppendingString:[@([STSticker stickersServerQueryCodeFromArray:stickers]) stringValue]];
        }
    } else{
        path = [[[@"places/" stringByAppendingString:[place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[pageN stringValue]];
    }
    
    [_manager requestFromPath:path completion:^(AFHTTPRequestOperation *operation, id data){
        NSError * error;
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
        
        if(json){
            NSDictionary * dic = json;
            NSNumber * count = dic[@"count"];
            NSUInteger pageCount = ([count unsignedIntegerValue] + 9)/10;
            NSArray * result = dic[@"results"];
            NSMutableArray * comments = [NSMutableArray arrayWithCapacity:result.count];
            
            BOOL err = NO;
            
            for(int i = 0; i < result.count; i++){
                STBoardComment * comment = [STBoardComment boardCommentFromServerJSONData:result[i]];
                if(comment){
                    comments[i] = comment;
                } else{
                    err = YES;
                }
            }
            
            if (!err) {
                if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^(){
                    completionBlock(comments, [count unsignedIntegerValue], pageCount);
                });
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
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock(error);
        });
        return;
    }];
}

#pragma mark - Insertion methods

- (void) postCommentWithText: (NSString*) text
                 andStickers: (NSArray*) stickers
               toPlaceWithId: (NSNumber *) placeId
                  completion: (void (^)(STBoardComment * comment)) completionBlock
                       error: (void (^)(NSError *error)) errorBlock{
    if(_user == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User is not logged in" code:41 userInfo:nil]);
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
                  }
                  
                  if (resultComment) {
                      if(completionBlock) dispatch_async(dispatch_get_main_queue(), ^{
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
