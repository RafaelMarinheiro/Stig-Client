//
//  STMapOverlayView.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 24/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "STTypes.h"

@interface STMapOverlayView : MKOverlayView

+ (STRankingCriteria) criteria;
+ (void) setCriteria: (STRankingCriteria) criteria;

- (id)initWithOverlay:(id <MKOverlay>)overlay;

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
                  inContext:(CGContextRef)ctx;

@end
