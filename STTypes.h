//
//  Types.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#ifndef PJPrototype_Types_h
#define PJPrototype_Types_h
#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

typedef struct{
    GLfloat x;
    GLfloat y;
} STPoint;

STPoint STPointMake(GLfloat x, GLfloat y);

typedef struct{
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat a;
} STColor;

STColor STColorMake(GLfloat r, GLfloat g, GLfloat b, GLfloat a);

typedef struct{
    STPoint a;
    STPoint b;
    STPoint c;
} STTriangle;

STTriangle STTriangleMake(STPoint a, STPoint b, STPoint c);

#endif
