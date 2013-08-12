//
//  STLocation.h
//  PJPrototype
//
//  Created by Lucas Tenório on 17/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface STLocation : NSObject

@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, strong) NSNumber *longitude;

+ (STLocation *)locationFromJSONData:(id) json;
+ (STLocation *)locationFromCLLocationCoordinate2D:(CLLocationCoordinate2D) location;
- (CLLocationCoordinate2D) locationCoordinate;
@end
