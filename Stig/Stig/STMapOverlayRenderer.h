//
//  MapOverlayRenderer.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//


#import <Foundation/Foundation.h>
#import "ESRenderer.h"
#import "STTypes.h"

#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#import "STPlace.h"

@interface STMapOverlayRenderer : NSObject <ESRenderer>
{
@private
	EAGLContext *context;

	// The pixel dimensions of the CAEAGLLayer
	GLint backingWidth;
	GLint backingHeight;

	// The OpenGL names for the framebuffer and renderbuffer used to render to this view
	GLuint defaultFramebuffer, colorRenderbuffer;

	/* the shader program object */
	GLuint program;

    //Interest points
    int _placeNumber;
    float _latlon[120];
    float _score[240];
    
    //Positioning
    STPoint _mapBottomLeft;
    STPoint _mapTopRight;
    STPoint _mapPosition;
    
    //Map criteria
    //0 -> Location
    //1 -> Social
    //2 -> Buzz
    //3 -> Overall
    int _criteria;
    
    GLfloat __screen[8];

    BOOL _needUpdate;
}

- (void) setMapRegion: (MKCoordinateRegion) region;
- (void) setUserLocation: (CLLocation *) location;
- (BOOL) addRelevantPlace: (STPlace *) place;
- (void) setCriteria: (STRankingCriteria) criteria;

- (void) setupTest;
- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end