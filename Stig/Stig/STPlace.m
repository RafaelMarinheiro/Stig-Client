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
        place.placeId = mainDictionary[@"id"];
        place.placeName = mainDictionary[@"name"];
        place.imageURL = mainDictionary[@"img"];
        place.placeDescription = mainDictionary[@"description"];
        place.location = [STLocation locationFromJSONData:mainDictionary[@"location"]];
        place.friends =  mainDictionary[@"friends"];
        place.stickers = mainDictionary[@"stickers"];
        place.ranking = [STRanking rankingFromJSONData:mainDictionary[@"ranking"]];
        return place;
    }
    return nil;
}
- (NSString *) description {
    return [NSString stringWithFormat:@"[%@: %@, %@, %@]",self.placeId, self.placeName, self.placeDescription,self.ranking.overall];
}
- (CLLocationCoordinate2D) coordinate{
    return [self.location locationCoordinate];
}
- (NSString *) title {
    return self.placeName;
}
- (NSString *) subtitle {
    return self.placeDescription;
}
@end
