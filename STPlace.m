//
//  STPlace.m
//  PJPrototype
//
//  Created by Lucas Tenório on 17/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STPlace.h"

@implementation STPlace
+ (STPlace *) placeFromJSONData:(id)json {
    if ([NSJSONSerialization isValidJSONObject:json]) {
        NSDictionary *mainDictionary = json;
        STPlace *place = [[STPlace alloc] init];
        place.name = mainDictionary[@"name"];
        place.imageURL = mainDictionary[@"url"];
        place.description = mainDictionary[@"description"];
        place.location = [STLocation locationFromJSONData:mainDictionary[@"location"]];
        place.friends =  mainDictionary[@"friends"];
        place.stickers = mainDictionary[@"stickers"];
        place.ranking = [STRanking rankingFromJSONData:mainDictionary[@"ranking"]];
        return place;
    }
    return nil;
}
@end
