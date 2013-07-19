//
//  STPlace.h
//  PJPrototype
//
//  Created by Lucas Tenório on 17/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "STLocation.h"
#import "STRanking.h"
@interface STPlace : NSObject
@property (nonatomic, strong) NSNumber *placeId;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *placeDescription;
@property (nonatomic, strong) STLocation *location;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSDictionary *stickers;
@property (nonatomic, strong) STRanking *ranking;
+ (STPlace *) placeFromJSONData:(id) json;
@end
