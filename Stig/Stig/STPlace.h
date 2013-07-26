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

@interface STPlace : NSObject <MKOverlay>

@property (nonatomic, strong) NSNumber *placeId;
@property (nonatomic, strong) NSString *placeName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *placeDescription;
@property (nonatomic, strong) STLocation *location;
@property (nonatomic, strong) NSArray *friends;
@property (nonatomic, strong) NSDictionary *stickers;
@property (nonatomic, strong) STRanking *ranking;
+ (STPlace *) placeFromJSONData:(id) json;
- (CLLocationCoordinate2D) coordinate;
- (MKMapRect) boundingMapRect;

- (MKCircle *) circle;
- (NSString *) title;
- (NSString *) subtitle;
@end

typedef NSComparisonResult(^STPlaceComparisonBlock)(id a, id b);
static STPlaceComparisonBlock const compareOverall = ^NSComparisonResult(id a, id b){
    if ([a isKindOfClass:[STPlace class]] && [b isKindOfClass:[STPlace class]]){
        NSLog(@"foda");
        STPlace *first = a;
        STPlace *second = b;
        if (first.ranking.overall < second.ranking.overall) {
            NSLog(@"ascending");
            return NSOrderedAscending;
        }else if (first.ranking.overall == second.ranking.overall){
            NSLog(@"same");
            return NSOrderedSame;
        } else {
            NSLog(@"descending");
            return NSOrderedDescending;
        }
    } else {
        
    }
    return NSOrderedSame;
};