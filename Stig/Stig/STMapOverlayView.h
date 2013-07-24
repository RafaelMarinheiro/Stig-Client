//
//  STMapOverlayView.h
//  Stig
//
//  Created by Rafael Farias Marinheiro on 24/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuartzCore/CAEAGLLayer.h"
#import "STMapOverlayRenderer.h"

@interface STMapOverlayView : UIView
{
@private
    STMapOverlayRenderer *renderer;
}

#pragma mark -
#pragma mark Data methods

- (void) setMapRegion: (MKCoordinateRegion) region;
- (void) setUserLocation: (CLLocation *) location;
- (BOOL) addRelevantPlace: (STPlace *) place;
- (void) setCriteria: (STRankingCriteria) criteria;

#pragma mark -
#pragma mark Draw Methods

- (void) drawView:(id)sender;


@end
