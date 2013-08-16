//
//  STFakeOverlord.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 08/08/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STFakeOverlord.h"
#import "STSafeMutableDictionary.h"

@interface STBoardCommentQueryContext : NSObject

@property (nonatomic, strong) NSDate * timestamp;
@property (nonatomic, strong) STPlace * place;
@property (nonatomic, strong) NSArray * stickers;

@end

@implementation STBoardCommentQueryContext

@end


@implementation STFakeOverlord{
    NSUInteger _counter;
    STSafeMutableDictionary * _users;
    STSafeMutableDictionary * _places;
    STSafeMutableDictionary * _commentsByPlaces;
    STSafeMutableDictionary * _tokenToBoardQuery;
    STUser * _user;
    NSLock * _lock;
}

- (id) init{
    self = [super init];
    if(self){
        _user = nil;
        _counter = 0;
        _lock = [[NSLock alloc] init];
        [self loadUsers];
        [self loadPlaces];
        [self loadComments];
        _tokenToBoardQuery = [[STSafeMutableDictionary alloc] init];
    }
    return self;
}

- (void) loadUsers{
    _users = [[STSafeMutableDictionary alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakeUsers" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    if (json) {
        NSDictionary *mainDictionary = json;
        NSArray *usersJSON = mainDictionary[@"users"];
        for (NSDictionary *userDictionary in usersJSON) {
            STUser *user = [STUser userFromJSONData:userDictionary];
            [_users setObject:user forKey:[user userId]];
        }
    }  else {
        NSLog(@"Erro ao ler o JSON de users");
    }
}

- (void) loadPlaces{
    _places = [[STSafeMutableDictionary alloc] init];
    _commentsByPlaces = [[STSafeMutableDictionary alloc] init];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakePlaces" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (json) {
        NSDictionary *main = json;
        NSArray *places = main[@"places"];
        
        for (NSDictionary *placeDictionary in places) {
            STPlace *place = [STPlace placeFromJSONData:placeDictionary];
            
            [_places setObject:place forKey:[place placeId]];
            [_commentsByPlaces setObject:[[STSafeMutableDictionary alloc] init] forKey:[place placeId]];
        }
    } else{
        NSLog(@"Erro ao ler o JSON de places");
    }
}

- (void) loadComments {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakeComments" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (json){
        NSDictionary *main = json;
        NSArray *comments = main[@"comments"];
        
        for (NSDictionary *commentDictionary in comments) {
            STBoardComment *comment = [STBoardComment boardCommentFromJSONData:commentDictionary];
            id board = [_commentsByPlaces objectForKey:[comment placeId]];
            if(board != nil){
                [board setObject:comment forKey:[comment commentId]];
            } else{
                NSLog(@"Erro besta ao ler o JSON de comments");
            }
        }
    }else {
        NSLog(@"Erro ao ler o JSON de comments");
    }
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
    
    if(_user != nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock(_user, place);
        });
        
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User is not logged in" code:41 userInfo:nil]);
        });
        
    }
 
}

#pragma mark - Authentication methods
- (void) signInUserWithId: (NSNumber *) userId
             withPassword: (NSString *) password
               completion: (void (^)(STUser * user)) completionBlock
                    error: (void (^) (NSError* error)) errorBlock{
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Sign-in is not allowed!" code:42 userInfo:nil]);
    });
    
}

- (void) authenticateUserWithId: (NSNumber *) userId
                   withPassword: (NSString *) password
                     completion: (void (^)(STUser * user)) completionBlock
                          error: (void (^) (NSError* error)) errorBlock{
    if(_user){
         errorBlock([[NSError alloc] initWithDomain:@"Someone is already logged in" code:42 userInfo:nil]);
    } else{
        id user = [_users objectForKey:userId];
        if(user != nil){
            _user = (STUser *) user;
            dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock(_user);
            });
            
        } else{
            dispatch_async(dispatch_get_main_queue(), ^(){
                errorBlock([[NSError alloc] initWithDomain:@"User does not exist" code:42 userInfo:nil]);
            });
        }
    }
}

- (void) signOutUser: (NSNumber *) userId
          completion: (void (^)()) completionBlock
               error: (void (^) (NSError* error)) errorBlock{
    if(_user != nil){
        _user = nil;
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock();
        });
        
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User is not logged in" code:41 userInfo:nil]);
        });
    }
}

#pragma mark - Raw Resolve methods

- (void) resolveUserById:(NSNumber *)userId
              requestNew:(BOOL) requestNew
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock{
    
    id user = [_users objectForKey:userId];
    if(user != nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock((STUser *) user);
        });
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User does not exist" code:42 userInfo:nil]);
        });
    }
}

//Place
- (void) resolvePlaceById:(NSNumber *) placeId
               requestNew:(BOOL) requestNew
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock{
    id place = [_places objectForKey:placeId];
    if(place != nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock((STPlace *) place);
        });
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Place does not exist" code:43 userInfo:nil]);
        });
    }
}

//Comment
- (void) resolveCommentById:(NSNumber *) commentId
                       fromPlace:(NSNumber *) placeId
                      requestNew:(BOOL) requestNew
                      completion:(void (^)(STBoardComment *place)) completionBlock
                           error:(void (^)(NSError *error)) errorBlock{
    id comments = [_commentsByPlaces objectForKey:placeId];
    if(comments != nil){
        id comment = [((STSafeMutableDictionary *) comments) objectForKey:commentId];
        if(comment != nil){
            dispatch_async(dispatch_get_main_queue(), ^(){
                completionBlock((STBoardComment *) comment);
            });
            
        } else{
            dispatch_async(dispatch_get_main_queue(), ^(){
                errorBlock([[NSError alloc] initWithDomain:@"Comment does not exist" code:44 userInfo:nil]);
            }); 
        }
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Place does not exist" code:43 userInfo:nil]);
        });
    }
}

#pragma mark - Simple Resolve Methods
- (void) resolveUserById:(NSNumber *)userId
              completion:(void (^)(STUser *user)) completionBlock
                   error:(void (^)(NSError *error)) errorBlock{
    [self resolveUserById:userId requestNew:YES completion:completionBlock error:errorBlock];
}


- (void) resolvePlaceById:(NSNumber *) placeId
               completion:(void (^)(STPlace *place)) completionBlock
                    error:(void (^)(NSError *error)) errorBlock{
    [self resolvePlaceById:placeId requestNew:YES completion:completionBlock error:errorBlock];
}

- (void) resolveCommentById:(NSNumber *) commentId
                  fromPlace:(NSNumber *) placeId
                 completion:(void (^)(STBoardComment *place)) completionBlock
                      error:(void (^)(NSError *error)) errorBlock{
    [self resolveCommentById:commentId fromPlace:placeId requestNew:YES completion:completionBlock error:errorBlock];
}

#pragma mark - Insertion methods

- (void) postComment: (STBoardComment*) comment
       toPlaceWithId: (NSNumber *) placeId
          completion: (void (^)(STBoardComment * comment)) completionBlock
               error: (void (^)(NSError *error)) errorBlock{
    
    if(_user == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User is not logged in" code:41 userInfo:nil]);
        });
    }
    
    id comments = [_commentsByPlaces objectForKey:placeId];
    
    if(comments != nil){
        NSNumber * commentId = nil;
        do{
            commentId = @(rand());
            if([comments objectForKey:commentId] != nil){
                commentId = nil;
            }
        } while(commentId == nil);
        
        comment.userId = _user.userId;
        comment.placeId = placeId;
        comment.commentId = commentId;
        comment.commentTimestamp = [[NSDate alloc] init];
        [comments setObject:comment forKey:commentId];
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock(comment);
        });
        
    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Place does not exist" code:43 userInfo:nil]);
        });
    }
}

- (void) postComment: (STBoardComment*) comment
           inReplyTo: (STBoardComment*) originalComment
          completion: (void (^)(STBoardComment * comment)) completionBlock
               error: (void (^)(NSError *error)) errorBlock{
    comment.replyId = originalComment.commentId;
    [self postComment:comment toPlaceWithId:originalComment.placeId completion:completionBlock error:errorBlock];
}

#pragma mark - Raw Get methods

- (void) getCheckInHistoryFromUser:(STUser*) user
                        pageNumber: (NSUInteger) pageNumber
                        requestNew: (BOOL) requestNew
                        completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock{
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Not implemented" code:43 userInfo:nil]);
    });
}

- (void) getCommentsFromPlace: (STPlace *) place
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   requestNew: (BOOL) requestNew
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock{
    
    id comments = [_commentsByPlaces objectForKey:place.placeId];
    
    if(comments != nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            completionBlock([comments allValues], [comments count]);
        });

    } else{
        dispatch_async(dispatch_get_main_queue(), ^(){
             errorBlock([[NSError alloc] initWithDomain:@"Place does not exist" code:43 userInfo:nil]);
        });
       
    }
}

- (void) getCommentsInReplyTo: (STBoardComment *) comment
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   requestNew: (BOOL) requestNew
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock{
    dispatch_async(dispatch_get_main_queue(), ^(){
        errorBlock([[NSError alloc] initWithDomain:@"Not implemented" code:43 userInfo:nil]);
    });
}


- (void) getPlacesWithSearchTerm: (NSString *) term
                      pageNumber: (NSUInteger) pageNumber
                      requestNew: (BOOL) requestNew
                      completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                           error: (void (^) (NSError* error)) errorBlock{
    dispatch_async(dispatch_get_main_queue(), ^(){
        completionBlock([_places allValues], [_places count]);
    });
    
}

#pragma mark - Simple Get methods

- (void) getCheckInHistoryFromUser:(STUser*) user
                        pageNumber: (NSUInteger) pageNumber
                        completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                             error: (void (^) (NSError* error)) errorBlock{
    [self getCheckInHistoryFromUser:user pageNumber:pageNumber requestNew:YES completion:completionBlock error:errorBlock];
}

- (void) getCommentsFromPlace: (STPlace *) place
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock{
    [self getCommentsFromPlace:place withStickers:stickers pageNumber:pageNumber requestNew:YES completion:completionBlock error:errorBlock];
}

- (void) getCommentsInReplyTo: (STBoardComment *) comment
                 withStickers: (NSArray *) stickers
                   pageNumber: (NSUInteger) pageNumber
                   completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                        error: (void (^) (NSError* error)) errorBlock{
    [self getCommentsInReplyTo:comment withStickers:stickers pageNumber:pageNumber requestNew:YES completion:completionBlock error:errorBlock];
}

- (void) getPlacesWithSearchTerm: (NSString *) term
                      pageNumber: (NSUInteger) pageNumber
                      completion: (void (^)(NSArray *array, NSUInteger page)) completionBlock
                           error: (void (^) (NSError* error)) errorBlock{
    [self getPlacesWithSearchTerm:term pageNumber:pageNumber requestNew:YES completion:completionBlock error:errorBlock];
}

- (STOverlordToken) requestTokenForBoard: (STPlace *) place
                   filteringWithStickers:(NSArray *) stickers{
    NSUInteger num = 0;
    [_lock lock];
        num = _counter;
        _counter++;
    [_lock unlock];

    STBoardCommentQueryContext * context = [[STBoardCommentQueryContext alloc] init];

    context.place = place;
    context.stickers = stickers;
    context.timestamp = [[NSDate alloc] init];

    [_tokenToBoardQuery setObject:context forKey:@(num)];

    return num;
}

- (void) getCommentAndUserForToken:(STOverlordToken)token andPosition:(NSUInteger)position completion:(void (^)(STBoardComment *, STUser *))completionBlock error:(void (^)(NSError *))errorBlock{

    STBoardCommentQueryContext * context = [_tokenToBoardQuery objectForKey:@(token)];

    if(context == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
    }

    STSafeMutableDictionary * comments = [_commentsByPlaces objectForKey:context.place.placeId];

    if(comments == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Place does not exist" code:43 userInfo:nil]);
        });
    }

    NSArray * commentArray = [comments allValues];

    commentArray = [commentArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [[((STBoardComment *) obj1) commentTimestamp] compare:[((STBoardComment *) obj2) commentTimestamp]] * (-1);
    }];

    NSUInteger now = 0;
    NSUInteger found = -1;
    for(int i = 0; i < [comments count]; i++){
        STBoardComment * comment = commentArray[i];

        //Checa se possui comentario
        if(context.stickers != nil){
            for(STSticker * mySticker in comment.commentStickers){
                for(STSticker * hisSticker in context.stickers){
                    if(mySticker.type == hisSticker.type){
                        if(now == position){
                            found = i;
                        }
                        now++;
                        goto GAMBI1;
                    }
                }
            }
        GAMBI1:
            now = now;
        } else{
            if(now == position){
                found = i;
            }
            now++;
        }

    }

    if(found == -1){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Comment does not exist" code:43 userInfo:nil]);
        });
    }

    STBoardComment * comment = commentArray[found];
    id user = [_users objectForKey: comment.userId];
    if(user == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"User does not exist" code:43 userInfo:nil]);
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^(){
        completionBlock(comment, user);
    });
}

- (void) getNumberOfCommentsForToken:(STOverlordToken)token completion:(void (^)(NSUInteger))completionBlock error:(void (^)(NSError *))errorBlock{

    STBoardCommentQueryContext * context = [_tokenToBoardQuery objectForKey:@(token)];

    if(context == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Token not found" code:43 userInfo:nil]);
        });
    }

    STSafeMutableDictionary * comments = [_commentsByPlaces objectForKey:context.place.placeId];

    if(comments == nil){
        dispatch_async(dispatch_get_main_queue(), ^(){
            errorBlock([[NSError alloc] initWithDomain:@"Place does not exist" code:43 userInfo:nil]);
        });
    }

    NSArray * commentArray = [comments allValues];

    commentArray = [commentArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [[((STBoardComment *) obj1) commentTimestamp] compare:[((STBoardComment *) obj2) commentTimestamp]] * (-1);
    }];
    NSLog(@"%@", context.stickers);
    NSUInteger now = 0;
    for(int i = 0; i < [comments count]; i++){
        STBoardComment * comment = commentArray[i];

        //Checa se possui comentario
        if(context.stickers != nil){
            for(STSticker * mySticker in comment.commentStickers){
                for(STSticker * hisSticker in context.stickers){
                    if(mySticker.type == hisSticker.type){
                        now++;
                        goto GAMBI2;
                    }
                }
            }
        GAMBI2:
            now = now;
        } else{
            now++;
        }

    }

    dispatch_async(dispatch_get_main_queue(), ^(){
        completionBlock(now);
    });
}

@end
