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

@public
    int numTriangles;
    STTriangle * triangleArray;
    STColor * colorArray;
}

- (void) render;
- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer;

@end