//
//  Types.h
//  PJPrototype
//
//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#ifndef __ST__TYPES__H__
#define __ST__TYPES__H__

#import <Foundation/Foundation.h>
#import <OpenGLES/EAGL.h>

typedef enum{
    ST_DISTANCE,
    ST_SOCIAL,
    ST_BUZZ,
    ST_OVERALL
} STRankingCriteria;

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

#endif
