//
//  STTypes.c
//  PJPrototype
//

//  Created by Lucas Tenório on 15/07/13.
//  Copyright (c) 2013 AwesomeInc. All rights reserved.
//

#include "STTypes.h"

STPoint STPointMake(GLfloat x, GLfloat y){
    STPoint p;
    p.x = x, p.y = y;
    return p;
}

STColor STColorMake(GLfloat r, GLfloat g, GLfloat b, GLfloat a){
    STColor c;
    c.r = r, c.g = g, c.b = b, c.a = a;
    return c;
}

STTriangle STTriangleMake(STPoint a, STPoint b, STPoint c){
    STTriangle t;
    t.a = a, t.b = b, t.c = c;
    return t;
}