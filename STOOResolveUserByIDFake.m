//
//  STOverlordOperationGetUserByIDFake.m
//  PJPrototype
//
//  Created by Lucas Tenório on 19/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STOOResolveUserByIDFake.h"

@implementation STOOResolveUserByIDFake
- (id) initWithUserId:(NSNumber *) userId importance:(STOverlordOperationImportance) importance completion:(void (^)(STUser *user)) completionBlock error:(STOErrorBlock) errorBlock {
    self = [super init];
    if (self) {
        _importance = importance;
        _cacheable = YES;
        _userId = userId;
        self.completionBlock = completionBlock;
        self.errorBlock = errorBlock;
    }
    return self;
}

- (BOOL) run {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fakeUsers" ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError * error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (json) {
        NSDictionary *mainDictionary = json;
        NSArray *usersJSON = mainDictionary[@"users"];
        for (NSDictionary *userDictionary in usersJSON) {
            NSNumber *userId = userDictionary[@"id"];
            if ([userId isEqualToNumber:self.userId]) {
                STUser *user = [STUser userFromJSONData:userDictionary];
                _output = user;
                return YES;
            }
        }
        _output = [NSError errorWithDomain:@"user not found or error in json" code:2 userInfo:nil];
        return NO;
    }  else {
        _output = error;
        return NO;
    }
}
- (void) runCompletionBlock {
    self.completionBlock(self.output);
}
- (void) runErrorBlock {
    self.errorBlock(self.output);
}
@end
