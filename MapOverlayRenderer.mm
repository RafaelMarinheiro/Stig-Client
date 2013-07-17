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
#import "Clarkson-Delaunay.h"


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

	}
    _allocatedTriangles = -2;
    _numTriangles = 0;
    _triangleArray = nil;
    _colorArray = nil;
    _needUpdate = YES;
    
	return self;
}

- (void) setSampledPoints: (int)numberOfPoints withColors: (STColor *)colorArray withPoints:(STPoint *)pointArray{
    
    unsigned int * list = BuildTriangleIndexList(pointArray, (float)RAND_MAX, numberOfPoints, 2, 1, &_numTriangles);
    
    _numTriangles /= 3;
    
    if(_numTriangles > 0){
        if(_numTriangles > _allocatedTriangles){
            if(_triangleArray){
                free(_triangleArray);
                _triangleArray = nil;
            }
            if(_colorArray){
                free(_colorArray);
                _colorArray = nil;
            }
            _triangleArray =(STTriangle *) malloc(_numTriangles * sizeof(STTriangle));
            _colorArray = (STColor *)malloc(3*_numTriangles * sizeof(STColor));
            
            _allocatedTriangles = _numTriangles;
        }
    }
    for (int triangle = 0; triangle < _numTriangles; triangle++){
        int a = list[3*triangle + 0];
        int b = list[3*triangle + 1];
        int c = list[3*triangle + 2];
        _triangleArray[triangle] = STTriangleMake(pointArray[a],
                                                  pointArray[b],
                                                  pointArray[c]);
        
        _colorArray[3*triangle + 0] = colorArray[a];
        _colorArray[3*triangle + 1] = colorArray[b];
        _colorArray[3*triangle + 2] = colorArray[c];
    }

    free(list);
     
}

- (void) setupTest {
    float down = -1;
    float left = -1;
    int steps = 5;
    float inc = 2.0/steps;
    STPoint * pointArray = (STPoint *) malloc(((steps+1)*(steps+1))*sizeof(STPoint));
    STColor * colArr = (STColor *) malloc(((steps+1)*(steps+1))*sizeof(STColor));

    int k = 0;
    for(int i = 0; i < steps+1; i++){
        for(int j = 0; j < steps+1; j++){

            pointArray[(steps+1)*i + j] = STPointMake(down, left);
            colArr[(steps+1)*i + j] = STColorMake(1.0, 0.0, 1.0, (rand()%256)/256.0);
            left += inc;
            k++;
        }
        left = -1;
        down += inc;
    }
    [self setSampledPoints:k withColors:colArr withPoints:pointArray];
    free(pointArray);
    free(colArr);
}

- (void)render {
    if(_needUpdate){
        [EAGLContext setCurrentContext:context];

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        glViewport(0, 0, backingWidth, backingHeight);

        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);

        if(_numTriangles > 0){
            // use shader program
            glUseProgram(program);
            
            // update attribute values
            glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, _triangleArray);
            glEnableVertexAttribArray(ATTRIB_VERTEX);
            glVertexAttribPointer(ATTRIB_COLOR, 4, GL_FLOAT, GL_TRUE, 0, _colorArray); //enable the normalized flag
            glEnableVertexAttribArray(ATTRIB_COLOR);
            
            glDrawArrays(GL_TRIANGLES, 0, 3*_numTriangles);
            
        }

        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    _needUpdate = NO;
}

- (BOOL)loadShaders {

	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;

	// create shader program
	program = glCreateProgram();

	// create and compile vertex shader
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"vsh"];
	if (!compileShader(&vertShader, GL_VERTEX_SHADER, (GLsizei)1, vertShaderPathname)) {
		destroyShaders(vertShader, fragShader, program);
		return NO;
	}

	// create and compile fragment shader
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"template" ofType:@"fsh"];
	if (!compileShader(&fragShader, GL_FRAGMENT_SHADER, (GLsizei)1, fragShaderPathname)) {
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
	// uniforms[UNIFORM_ENUM] = glGetUniformLocation(program, "<UNIFORM_PARAMETER_NAME>");
    
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
    
    if(_triangleArray) free(_triangleArray);
    if(_colorArray) free(_colorArray);
	
}

@end
