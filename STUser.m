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
        return user;
    }
    return nil;
}
- (NSString *) description {
    return [NSString stringWithFormat:@"[%@: %@]",self.userId,self.userName];
}
@end
