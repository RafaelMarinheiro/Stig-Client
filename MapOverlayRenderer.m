//
//  MapOverlayRenderer.m
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import "MapOverlayRenderer.h"
#import "Shaders.h"
#import "matrix.h"

// uniform index
enum {
	UNIFORM_MODELVIEW_PROJECTION_MATRIX,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// attribute index
enum {
	ATTRIB_VERTEX,
	ATTRIB_COLOR,
	NUM_ATTRIBUTES
};

@interface MapOverlayRenderer (PrivateMethods)
- (BOOL) loadShaders;
@end

@implementation MapOverlayRenderer

// Create an ES 2.0 context
- (id <ESRenderer>) init
{
	if (self = [super init])
	{
		context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

        if (!context || ![EAGLContext setCurrentContext:context] || ![self loadShaders])
		{

            return nil;
        }

		// Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
		glGenFramebuffers(1, &defaultFramebuffer);
		glGenRenderbuffers(1, &colorRenderbuffer);
		glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
		glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
		glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        [self setup];
	}

	return self;
}



- (void) setup {

    float down = -1;
    float left = -1;
    int steps = 10;
    float inc = 2.0/steps;
    STPoint * pointArray = malloc((steps+1)*(steps+1)*sizeof(STPoint));
    STColor * colArr = malloc((steps+1)*(steps+1)*sizeof(STColor));

    for(int i = 0; i < steps+1; i++){
        for(int j = 0; j < steps+1; j++){
            pointArray[(steps+1)*i + j] = STPointMake(down, left);
            colArr[(steps+1)*i + j] = STColorMake(1.0, 0.0, 1.0, (rand()%256)/256.0);
            left += inc;
        }
        left = -1;
        down += inc;
    }
    triangleArray = malloc(2*steps*steps*sizeof(STTriangle));

    colorArray = malloc(2*3*steps*steps*sizeof(STColor));

    numTriangles = 0;

    for(int i = 0; i < steps; i++) {
        for(int j = 0; j < steps; j++){
            triangleArray[numTriangles] = STTriangleMake(pointArray[(steps+1)*i + j],
                                                         pointArray[(steps+1)*i+(j+1)],
                                                         pointArray[(steps+1)*(i+1) + j]);

            colorArray[3*numTriangles + 0] = colArr[(steps+1)*i + j];
            colorArray[3*numTriangles + 1] = colArr[(steps+1)*i + (j+1)];
            colorArray[3*numTriangles + 2] = colArr[(steps+1)*(i+1) + j];

            numTriangles++;

            triangleArray[numTriangles] = STTriangleMake(pointArray[(steps+1)*(i+1) + (j+1)],
                                                         pointArray[(steps+1)*i+(j+1)],
                                                         pointArray[(steps+1)*(i+1) + j]);

            colorArray[3*numTriangles + 0] = colArr[(steps+1)*(i+1) + (j+1)];
            colorArray[3*numTriangles + 1] = colArr[(steps+1)*i + (j+1)];
            colorArray[3*numTriangles + 2] = colArr[(steps+1)*(i+1) + j];
            numTriangles++;
        }
    }
}

- (void)render {

    [EAGLContext setCurrentContext:context];

    glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);

    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
    glClear(GL_COLOR_BUFFER_BIT);

	// use shader program
	glUseProgram(program);

	// handle viewing matrices
	GLfloat proj[16];
	// setup projection matrix (orthographic)
	mat4f_LoadOrtho(-1.0f, 1.0f, -1.5f, 1.5f, -1.0f, 1.0f, proj);

	// update uniform values
	glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_PROJECTION_MATRIX], 1, GL_FALSE, proj);

	// update attribute values
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, triangleArray);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_COLOR, 4, GL_FLOAT, 1, 0, colorArray); //enable the normalized flag
    glEnableVertexAttribArray(ATTRIB_COLOR);

	// draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 3*numTriangles);

    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER];
}

- (BOOL)loadShaders {

	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;

	// create shader program
	program = glCreateProgram();

	// create and compile vertex shader
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"vsh"];
	if (!compileShader(&vertShader, GL_VERTEX_SHADER, 1, vertShaderPathname)) {
		destroyShaders(vertShader, fragShader, program);
		return NO;
	}

	// create and compile fragment shader
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"fsh"];
	if (!compileShader(&fragShader, GL_FRAGMENT_SHADER, 1, fragShaderPathname)) {
		destroyShaders(vertShader, fragShader, program);
		return NO;
	}

	// attach vertex shader to program
	glAttachShader(program, vertShader);

	// attach fragment shader to program
	glAttachShader(program, fragShader);

	// bind attribute locations
	// this needs to be done prior to linking
	glBindAttribLocation(program, ATTRIB_VERTEX, "position");
	glBindAttribLocation(program, ATTRIB_COLOR, "color");

	// link program
	if (!linkProgram(program)) {
		destroyShaders(vertShader, fragShader, program);
		return NO;
	}

	// get uniform locations
	uniforms[UNIFORM_MODELVIEW_PROJECTION_MATRIX] = glGetUniformLocation(program, "modelViewProjectionMatrix");

	// release vertex and fragment shaders
	if (vertShader) {
		glDeleteShader(vertShader);
		vertShader = 0;
	}
	if (fragShader) {
		glDeleteShader(fragShader);
		fragShader = 0;
	}

	return YES;
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{
	// Allocate color buffer backing based on the current layer size
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
	{
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        return NO;
    }

    return YES;
}

- (void) dealloc
{
	// tear down GL
	if (defaultFramebuffer)
	{
		glDeleteFramebuffers(1, &defaultFramebuffer);
		defaultFramebuffer = 0;
	}

	if (colorRenderbuffer)
	{
		glDeleteRenderbuffers(1, &colorRenderbuffer);
		colorRenderbuffer = 0;
	}

	// realease the shader program object
	if (program)
	{
		glDeleteProgram(program);
		program = 0;
	}

	// tear down context
	if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	
	
	context = nil;
	
}

@end
