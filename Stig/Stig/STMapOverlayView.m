//
//  STMapOverlayView.m
//  Stig
//
//  Created by Rafael Farias Marinheiro on 24/07/13.
//  Copyright (c) 2013 Stig inc. All rights reserved.
//

#import "STMapOverlayView.h"
#import "STPlace.h"

@implementation STMapOverlayView

static STRankingCriteria _criteria = ST_BUZZ;

+ (STRankingCriteria) criteria{
    return _criteria;
}

+ (void) setCriteria:(STRankingCriteria)criteria{
    _criteria = criteria;
}

- (id)initWithOverlay:(id <MKOverlay>)overlay
{
    return [super initWithOverlay:overlay];
}

- (double) computeRelevance{
    double buzz = [((STPlace*)self.overlay).ranking.buzz doubleValue]/1000;
    double social = [((STPlace*)self.overlay).ranking.social doubleValue]/1000;
    
    if([STMapOverlayView criteria] == ST_BUZZ){
        return 0.9*buzz;
    } else if([STMapOverlayView criteria] == ST_SOCIAL){
        return 0.9*social;
    } else{
        double rank = [((STPlace*)self.overlay).ranking.buzz doubleValue]/1000;
        return 0.45*(buzz+social);
    }
    return 0.5;
}

- (double) computeRadius{
    return 1.0;
}

- (void)drawMapRect:(MKMapRect)mapRect
          zoomScale:(MKZoomScale)zoomScale
          inContext:(CGContextRef)ctx
{
    // Get the overlay bounding rectangle.
    MKMapRect  theMapRect = [self.overlay boundingMapRect];
    CGRect theRect = [self rectForMapRect:theMapRect];

    CGPoint center;
    center = CGPointMake(CGRectGetMidX(theRect), CGRectGetMidY(theRect));
    double radius = (CGRectGetMaxX(theRect) - CGRectGetMidX(theRect))*[self computeRadius];
    if(zoomScale < 0.0005){
        return;
    }
    
    
    CGContextClipToRect(ctx, theRect);
    
    // Set up the gradient color and location information.
    CGColorSpaceRef myColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[5] = {0.0, 0.25, 0.50, 0.75, 1.0};

    if([STMapOverlayView criteria] == ST_BUZZ){
         CGFloat components[20] = {
                                    0.87, 0.23, 0.16, 1.0*[self computeRelevance],
                                    0.87, 0.23, 0.16, 0.8*[self computeRelevance],
                                    0.87, 0.23, 0.16, 0.35*[self computeRelevance],
                                    0.87, 0.23, 0.16, 0.1*[self computeRelevance],
                                    0.87, 0.23, 0.16, 0.0*[self computeRelevance]
                                 };
        
        // Create the gradient.
        CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorSpace, components, locations, 5);
        
        // Draw.
        CGContextDrawRadialGradient(ctx, myGradient, center, 0, center, radius, kCGGradientDrawsBeforeStartLocation);
        
        // Clean up.
        CGColorSpaceRelease(myColorSpace);
        CGGradientRelease(myGradient);
    } else if([STMapOverlayView criteria] == ST_SOCIAL){
        CGFloat components[20] = {
                                    1.0, 0.65, 0.25, 1.0*[self computeRelevance],
                                    1.0, 0.65, 0.25, 0.8*[self computeRelevance],
                                    1.0, 0.65, 0.25, 0.35*[self computeRelevance],
                                    1.0, 0.65, 0.25, 0.1*[self computeRelevance],
                                    1.0, 0.65, 0.25, 0.0*[self computeRelevance]
                                };
        
        // Create the gradient.
        CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorSpace, components, locations, 5);
        
        // Draw.
        CGContextDrawRadialGradient(ctx, myGradient, center, 0, center, radius, kCGGradientDrawsBeforeStartLocation);
        
        // Clean up.
        CGColorSpaceRelease(myColorSpace);
        CGGradientRelease(myGradient);
    } else{
        CGFloat components[20] = {
                            1.0, 0.0, 0.0, 1.0*[self computeRelevance],
                            1.0, 0.0, 0.0, 0.8*[self computeRelevance],
                            1.0, 0.0, 0.0, 0.35*[self computeRelevance],
                            1.0, 0.0, 0.0, 0.1*[self computeRelevance],
                            1.0, 0.0, 0.0, 0.0*[self computeRelevance]
                        };
        
        // Create the gradient.
        CGGradientRef myGradient = CGGradientCreateWithColorComponents(myColorSpace, components, locations, 5);
        
        // Draw.
        CGContextDrawRadialGradient(ctx, myGradient, center, 0, center, radius, kCGGradientDrawsBeforeStartLocation);
        
        // Clean up.
        CGColorSpaceRelease(myColorSpace);
        CGGradientRelease(myGradient);
    }
    
}

@end
