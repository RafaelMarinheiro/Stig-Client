//
//  STUser.m
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STUser.h"

@implementation STUser
+(STUser *) userFromJSONData:(id)json {
    if ([NSJSONSerialization isValidJSONObject:json] && [json isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = json;
        STUser *user = [[STUser alloc] init];
        user.userId = dictionary[@"id"];
        user.userImageURL = dictionary[@"img"];
        user.userName = dictionary[@"name"];
        user.location = [STLocation locationFromJSONData:dictionary[@"location"]];
        user.userPlaceId = dictionary[@"place"];
        user.points = dictionary[@"points"];
        return user;
    }
    return nil;
}

+(STUser *) userFromServerJSONData:(id)json {
    if ([json isKindOfClass:[NSDictionary class]]) {
        NSLog(@"USER CREATION FROM SERVER!");
        NSDictionary *dictionary = json;
        STUser *user = [[STUser alloc] init];
        user.userId = dictionary[@"id"];
        user.userImageURL = dictionary[@"avatar"];
        user.userName = [[dictionary[@"first_name"] stringByAppendingString:@" "] stringByAppendingString:dictionary[@"last_name"]];
        user.location = nil;
        user.userPlaceId = dictionary[@"place"];
        user.points = dictionary[@"points"];
        return user;
    }
    return nil;
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[%@: %@ %@]",self.userId,self.userName,self.userImageURL];
}
@end
