//
//  STRanking.m
//  PJPrototype
//
//  Created by Lucas Tenório on 17/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STRanking.h"

@implementation STRanking
+(STRanking *) rankingFromJSONData:(id)json {
    if ([NSJSONSerialization isValidJSONObject:json]) {
        NSDictionary *mainDictionary = json;
        STRanking *ranking = [[STRanking alloc] init];
        ranking.distance = mainDictionary[@"distance"];
        ranking.social = mainDictionary[@"social"];
        ranking.buzz = mainDictionary[@"buzz"];
        ranking.overall = mainDictionary[@"overall"];

        return ranking;
    }
    return nil;
}
@end
