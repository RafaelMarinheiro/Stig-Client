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

    int _allocatedTriangles;
    int _numTriangles;
    STTriangle * _triangleArray;
    STColor * _colorArray;
    
    BOOL _needUpdate;
}

- (void) setupTest;
- (void) render;
- (void) setSampledPoints: (int)numberOfPoints withColors: (STColor *)colorArray withPoints:(STPoint *)pointArray;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end