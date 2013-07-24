//
//  STMapOverlayView.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 24/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STMapOverlayView.h"

@implementation STMapOverlayView


#pragma mark -
#pragma mark Init Methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self config];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self config];
    }
    return self;
}

- (void) layoutSubviews
{
	[renderer resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}
- (void) config {
    self.backgroundColor = [UIColor clearColor];
    renderer = [[STMapOverlayRenderer alloc] init];
}

+(Class)layerClass {
    return [CAEAGLLayer class];
}

#pragma mark -
#pragma mark Data methods

- (void) setMapRegion: (MKCoordinateRegion) region{
    [renderer setMapRegion:region];
}
- (void) setUserLocation: (CLLocation *) location{
    [renderer setUserLocation:location];
}
- (BOOL) addRelevantPlace: (STPlace *) place{
    return [renderer addRelevantPlace:place];
}
- (void) setCriteria: (STRankingCriteria) criteria{
    [renderer setCriteria:criteria];
}

#pragma mark -
#pragma mark Draw Methods
- (void) drawView:(id)sender
{
    [renderer render];
}

@end
