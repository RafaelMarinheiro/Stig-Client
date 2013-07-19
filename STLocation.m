//
//  STLocation.m
//  PJPrototype
//
//  Created by Lucas Tenório on 17/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "STLocation.h"



@implementation STLocation
+ (STLocation *) locationFromJSONData:(id)json {
    if ([NSJSONSerialization isValidJSONObject:json]) {
        NSDictionary *mainDictionary = json;
        STLocation *location = [[STLocation alloc] init];
        location.latitude = mainDictionary[@"lat"];
        location.longitude = mainDictionary[@"lon"];
        return location;
        
    }
    return nil;
}
+ (STLocation *)locationFromCLLocationCoordinate2D:(CLLocationCoordinate2D) location{
    STLocation *newLocation = [[STLocation alloc] init];
    newLocation.longitude = [NSNumber numberWithDouble:location.longitude];
    newLocation.latitude = [NSNumber numberWithDouble:location.latitude];
    return newLocation;
}
- (CLLocationCoordinate2D) locationCoordinate {
    return CLLocationCoordinate2DMake([[self latitude] doubleValue], [[self longitude] doubleValue]);
}

- (NSString *) description {
    return [NSString stringWithFormat:@"[%@ %@]",self.latitude, self.longitude];
}
@end
