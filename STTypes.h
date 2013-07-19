//
//  Types.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

typedef struct{
    GLfloat x;
    GLfloat y;
} STPoint;

STPoint STPointMake(float x, float y);

typedef struct{
    GLfloat r;
    GLfloat g;
    GLfloat b;
    GLfloat a;
} STColor;

STColor STColorMake(float r, float g, float b, float a);

typedef struct{
    STPoint a;
    STPoint b;
    STPoint c;
} STTriangle;

STTriangle STTriangleMake(STPoint a, STPoint b, STPoint c);

STPoint STPointMake(float x, float y){
    STPoint p;
    p.x = (GLfloat) x, p.y = (GLfloat) y;
    return p;
}

STColor STColorMake(float r, float g, float b, float a){
    STColor c;
    c.r = (GLfloat) r, c.g = (GLfloat) g, c.b = (GLfloat) b, c.a = (GLfloat) a;
    return c;
}

STTriangle STTriangleMake(STPoint a, STPoint b, STPoint c){
    STTriangle t;
    t.a = a, t.b = b, t.c = c;
    return t;
}
