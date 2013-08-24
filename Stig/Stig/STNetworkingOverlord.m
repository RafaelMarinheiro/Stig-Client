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


@implementation STNetworkingOverlord{
    AFHTTPClient * _client;
    NSUInteger _counter;
    NSCache * _users;
    NSCache * _places;
    NSCache * _commentsByPlaces;
    STSafeMutableDictionary * _tokenToBoardQuery;
    STSafeMutableDictionary * _tokenToCheckInQuery;
    STSafeMutableDictionary * _tokenToPlacesQuery;
    STUser * _user;
    NSString * _fb_id;
    NSString * _fb_accesstoken;
    NSLock * _lock;
}


- (id) init{
    self = [super init];
    if(self){
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://api.stigapp.co/"]];
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
    return nil;
}

- (void) setUserLocation:(STLocation *)userLocation{
    return;
}

#pragma mark - Check-In methods

- (void) checkInPlace: (STPlace *) place
           completion: (void (^)(STUser * user, STPlace * place)) completionBlock
                error: (void (^) (NSError* error)) errorBlock{
    
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Not implemented" code:43 userInfo:nil]);
    });
    
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

- (void) authenticateUserWithId: (NSNumber *) userId
                   withPassword: (NSString *) password
                     completion: (void (^)(STUser * user)) completionBlock
                          error: (void (^) (NSError* error)) errorBlock{
    _user = nil;
    _fb_id = [userId stringValue];
    _fb_accesstoken = password;
    
    [_client setAuthorizationHeaderWithUsername:_fb_id password:_fb_accesstoken];
    
    NSString * path = @"/users/me/";
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSData * data) {
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
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_client clearAuthorizationHeader];
        if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock(error);
        });
    }];
    
    [_client enqueueHTTPRequestOperation:operation];
}
     
- (void) signOutWithCompletion: (void (^)()) completionBlock
                         error: (void (^) (NSError* error)) errorBlock{
    _user = nil;
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
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];

    [operation setCompletionBlockWithSuccess:
    ^(AFHTTPRequestOperation *operation, id data){
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
    }failure: ^(AFHTTPRequestOperation * operation, NSError *error){
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
    
    [_client enqueueHTTPRequestOperation:operation];
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
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id data){
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
     }failure: ^(AFHTTPRequestOperation * operation, NSError *error){
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
    
    [_client enqueueHTTPRequestOperation:operation];
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
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path:path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id data){
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
     }failure: ^(AFHTTPRequestOperation * operation, NSError *error){
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
    
    [_client enqueueHTTPRequestOperation:operation];
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
    
    STPlacesQueryContext * context = [[STPlacesQueryContext alloc] initWithQueryString:term];
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
    
    NSNumber * page = @(1);
    NSNumber * baseNumber = @(0);
    
    NSString * path = nil;
    if(context.queryString){
        path = [[[@"places/?page=" stringByAppendingString:[page stringValue]] stringByAppendingString: @"&q="] stringByAppendingString:context.queryString];
    } else{
        path = [@"places/?page=" stringByAppendingString:[page stringValue]];
    }
    
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STPlace * resultPlace = nil;
         
         if(json){
             NSDictionary * dic = json;
             NSNumber * count = dic[@"count"];
             [context.cache setObject:count forKey:@(-1)];
             NSLog(@"%@ objects found", count);
             NSArray * result = dic[@"results"];
             for(int i = 0; i < result.count; i++){
                 STPlace * place = [STPlace placeFromServerJSONData:result[i]];
                 if(place){
                     [_places setObject:place forKey:place.placeId];
                     NSUInteger currentPosition = i+[baseNumber unsignedIntegerValue];
                     [context.cache setObject:place.placeId forKey:(@(currentPosition))];
                     NSLog(@"Cached %@ in position %d for token %d", place, currentPosition, token);
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
     }failure: ^(AFHTTPRequestOperation * operation, NSError *error){
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
    
    [_client enqueueHTTPRequestOperation:operation];
  
}

- (void) getCheckInPlaceForToken: (STOverlordToken) token
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
    
    NSNumber * page = @(1);
    NSNumber * baseNumber = @(0);
    
    NSString * path = nil;
    path = [[[[@"users/" stringByAppendingString:[context.user userName]] stringByAppendingString:@"/checkins/"] stringByAppendingString:@"?page="] stringByAppendingString:[page stringValue]];
    
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id data){
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
     }failure: ^(AFHTTPRequestOperation * operation, NSError *error){
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
    
    [_client enqueueHTTPRequestOperation:operation];
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
    
    NSNumber * page = @(1);
    NSNumber * baseNumber = @(0);
    
    NSString * path = nil;
    if(context.stickers){
        path = [[[@"places/" stringByAppendingString:[context.place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[page stringValue]];
    } else{
        path = [[[@"places/" stringByAppendingString:[context.place.placeId stringValue]] stringByAppendingString:@"/comments/?page="] stringByAppendingString:[page stringValue]];
    }
    
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STBoardComment * resultComment = nil;
         
         if(json){
             NSDictionary * dic = json;
             NSNumber * count = dic[@"count"];
             [context.cache setObject:count forKey:@(-1)];
             NSLog(@"%@ objects found", count);
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
                     
                     NSLog(@"Cached %@ in position %d for token %d", comment, currentPosition, token);
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
     }failure: ^(AFHTTPRequestOperation * operation, NSError *error){
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
    
    [_client enqueueHTTPRequestOperation:operation];
    
}


#pragma mark - Token counting

- (void) getNumberOfCommentsForToken: (STOverlordToken) token
                          completion: (void (^) (NSUInteger numberOfComments)) completionBlock
                               error: (void (^) (NSError* error)) errorBlock{
    
    STBoardCommentQueryContext * context = [_tokenToBoardQuery objectForKey:@(token)];
    if(context){
        [self getCommentAndUserForToken:token andPosition:0 completion:^(STBoardComment *comment, STUser *user) {
            completionBlock([[context.cache objectForKey:@(-1)] unsignedIntegerValue]);
        } error:errorBlock];
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
        } error:errorBlock];
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
        } error:errorBlock];
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
                 NSLog(@"%@", data);
             } failure:^(AFHTTPRequestOperation * operation, NSError *error) {
                 if(errorBlock) dispatch_async(dispatch_get_main_queue(), ^{
                     errorBlock(error);
                 });
             }];
}


@end
