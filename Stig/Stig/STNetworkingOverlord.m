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


@implementation STNetworkingOverlord{
    AFHTTPClient * _client;
    NSUInteger _counter;
    NSCache * _users;
    NSCache * _places;
    NSCache * _commentsByPlaces;
    STSafeMutableDictionary * _tokenToBoardQuery;
    STUser * _user;
    NSLock * _lock;
}


- (id) init{
    self = [super init];
    if(self){
        _client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://stig-server.herokuapp.com/api/"]];
        _user = nil;
        _counter = 0;
        _lock = [[NSLock alloc] init];
        _users = [[NSCache alloc] init];
        _places = [[NSCache alloc] init];
        _commentsByPlaces = [[NSCache alloc] init];
        _tokenToBoardQuery = [[STSafeMutableDictionary alloc] init];
    }
    return self;
}

- (STUser *) user{
    return _user;
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
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Not implemented" code:43 userInfo:nil]);
    });
}

- (void) signOutUser: (NSNumber *) userId
          completion: (void (^)()) completionBlock
               error: (void (^) (NSError* error)) errorBlock{
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Not implemented" code:43 userInfo:nil]);
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
    
    NSString * path = [@"users/" stringByAppendingString:[userId stringValue]];
    
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
            errorBlock(error);
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
    
    NSString * path = [@"places/" stringByAppendingString:[placeId stringValue]];
    
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
                 [_users setObject:place forKey:place.placeId];
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
             errorBlock(error);
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
        comment = [_places objectForKey:placeId];
        if(comment){
            dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock((STPlace *) place);
            });
            return;
        }
    }
    
    NSString * path = [[[@"places/" stringByAppendingString:[placeId stringValue]] stringByAppendingString:@"/comments/"] stringByAppendingString:[commentId stringValue]];
    
    NSMutableURLRequest * request = [_client requestWithMethod:@"GET" path: path parameters:nil];
    AFHTTPRequestOperation * operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation setCompletionBlockWithSuccess:
     ^(AFHTTPRequestOperation *operation, id data){
         NSError * error;
         id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
         STBoardComment * comment = nil;
         
         if(json){
             NSDictionary * dic = json;
             place = [STPlace placeFromServerJSONData:dic];
             if(place){
                 [_users setObject:place forKey:place.placeId];
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
             errorBlock(error);
         });
         return;
     }];
    
    [_client enqueueHTTPRequestOperation:operation];
}

@end
