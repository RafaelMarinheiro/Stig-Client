#include "STTypes.h"



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

