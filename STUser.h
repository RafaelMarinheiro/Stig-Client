//
//  STUser.h
//  PJPrototype
//
//  Created by Lucas Tenório on 18/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLocation.h"
@interface STUser : NSObject
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSString *userImageURL;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) STLocation *location;
@property (nonatomic, strong) NSNumber *userPlaceId;
+(STUser *) userFromJSONData:(id)json;
@end
