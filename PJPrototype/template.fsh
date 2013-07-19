#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//Interest points
uniform int placeNumber;
uniform vec2 latlon[50];
uniform vec4 score[50];

//Map positioning
uniform vec2 mapBottomRight;
uniform vec2 mapTopLeft;
uniform vec2 mapPosition;

//Map criteria
//0 -> Location
//1 -> Social
//2 -> Buzz
//3 -> Overall
uniform int criteria;

//Screen size attributes
uniform float screenWidth;
uniform float screenHeight;

void main()
{
    float xx = gl_FragCoord.x*1.0;
    float yy = gl_FragCoord.y*1.0;
    
    float cx = 0.75*screenWidth;
    float cy = 0.75*screenHeight;
    
    float dist = sqrt((xx - cx)*(xx-cx) + (yy-cy)*(yy-cy));
    
    float radius = 100.0;
    
    float a = (radius*radius-dist*dist)/(radius*radius);
    a = clamp(a, 0.0, 1.0);
    
    cx = 0.4*screenWidth;
    cy = 0.6*screenHeight;
    
    dist = sqrt((xx - cx)*(xx-cx) + (yy-cy)*(yy-cy));
    
    radius = 75.0;
    
    float b = (radius*radius-dist*dist)/(radius*radius);
    b = clamp(b, 0.0, 1.0);
    
    cx = 0.7*screenWidth;
    cy = 0.4*screenHeight;
    
    dist = sqrt((xx - cx)*(xx-cx) + (yy-cy)*(yy-cy));
    
    radius = 80.0;
    
    float c = (radius*radius-dist*dist)/(radius*radius);
    c = clamp(c, 0.0, 1.0);
    
    
    float alpha = clamp(a+b+c, 0.0, 1.0);
    gl_FragColor = vec4(a, b, c, alpha);
    
    if(alpha == 0.0){
        gl_FragColor = vec4(0.0, 0.0, 1.0, 0.0);
    }
}
