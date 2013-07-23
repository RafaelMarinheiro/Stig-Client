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


enum FILTER_MODE{
    ST_LOCATION,
    ST_SOCIAL,
    ST_BUZZ,
    ST_OVERALL
};

// uniform index
enum {
	UNIFORM_SCREEN_SIZE,
    
    UNIFORM_PLACE_NUMBER,
    UNIFORM_LATLON_BUFFER,
    UNIFORM_SCORE_BUFFER,
    UNIFORM_CRITERIA,
    
    UNIFORM_MAP_BOTTOMLEFT,
    UNIFORM_MAP_TOPRIGHT,
    UNIFORM_MAP_POSITION,
    
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
    _needUpdate = YES;
    
    __screen[0] =  -1;
    __screen[1] =  -1;
    __screen[2] =  1;
    __screen[3] =  -1;
    __screen[4] =  -1;
    __screen[5] =  1;
    __screen[6] =  1;
    __screen[7] =  1;
    
	return self;
}

- (void) setPlaces:(NSArray *)places{
    for (int i = 0; i < [places count]; i++) {
        STPlace * place = [places objectAtIndex:i];
        _latlon[i] = STPointMake([place.location.latitude floatValue], [place.location.longitude floatValue]);
        
        _score[4*i + 0] = [place.ranking.distance floatValue];
        _score[4*i + 1] = [place.ranking.social floatValue];
        _score[4*i + 2] = [place.ranking.buzz floatValue];
        _score[4*i + 3] = [place.ranking.overall floatValue];
    }
}

- (void) setupTest {

}



- (void)render {
    printf("%d\n", GL_MAX_VERTEX_UNIFORM_VECTORS);
    if(_needUpdate){
        [EAGLContext setCurrentContext:context];

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_SRC_ALPHA);
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        glViewport(0, 0, backingWidth, backingHeight);

        glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        glClear(GL_COLOR_BUFFER_BIT);

            // use shader program
            glUseProgram(program);
        
        glUniform2f(uniforms[UNIFORM_SCREEN_SIZE], backingWidth*1.0f, backingHeight*1.0f);
        
            // update attribute values
            glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, GL_FALSE, 0, __screen);
            glEnableVertexAttribArray(ATTRIB_VERTEX);
//            glVertexAttribPointer(ATTRIB_COLOR, 4, GL_FLOAT, GL_TRUE, 0, _colorArray); //enable the normalized flag
//            glEnableVertexAttribArray(ATTRIB_COLOR);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    _needUpdate = YES;
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
	//glBindAttribLocation(program, ATTRIB_COLOR, "color");

	// link program
	if (!linkProgram(program)) {
		destroyShaders(vertShader, fragShader, program);
		return NO;
	}

	// get uniform locations
    uniforms[UNIFORM_PLACE_NUMBER] = glGetUniformLocation(program, "placeNumber");
    uniforms[UNIFORM_LATLON_BUFFER] = glGetUniformLocation(program, "latlon");
    uniforms[UNIFORM_MAP_BOTTOMLEFT] = glGetUniformLocation(program, "mapBottomLeft");
    uniforms[UNIFORM_MAP_TOPRIGHT] = glGetUniformLocation(program, "mapTopRight");
    uniforms[UNIFORM_MAP_POSITION] = glGetUniformLocation(program, "mapPosition");
    uniforms[UNIFORM_CRITERIA] = glGetUniformLocation(program, "criteria");
	uniforms[UNIFORM_SCREEN_SIZE] = glGetUniformLocation(program, "screenSize");
    
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


    printf("%d %d\n", backingWidth, backingHeight);
    
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
