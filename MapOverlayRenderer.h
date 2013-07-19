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

@interface MapOverlayRenderer : NSObject <ESRenderer>
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
    STPoint _latlon[60];
    float _score[240];
    
    //Positioning
    STPoint _mapBottomRight;
    STPoint _mapTopLeft;
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

- (void) setupTest;
- (void) render;
- (void) setPlaces: (NSArray *) place;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end