#ifdef GL_ES
// define default precision for float, vec, mat.
precision highp float;
#endif

//Interest points
uniform int placeNumber;
uniform vec2 latlon[50];
uniform vec2 score[50];

//Map positioning
uniform vec2 mapBottomLeft;
uniform vec2 mapTopRight;
uniform vec2 mapPosition;

//Map criteria
//0 -> Location
//1 -> Social
//2 -> Buzz
//3 -> Overall
uniform int criteria;

//Screen size attributes
uniform vec2 screenSize;

float latlonSqDistance(in vec2 latlon1, in vec2 latlon2){
    float earthRadius = 6371.0;
    vec2 dif = vec2((latlon2.y-latlon1.y) * cos((latlon1.x+latlon2.x)/2.0), (latlon2.x-latlon1.x));
    return dot(dif, dif)*earthRadius*earthRadius;
}

float gaussian(in float sqDist, in float radius){
    float dist = sqDist/(radius*radius);
    return exp(-(dist));
}

vec2 computeCoordinates(in vec2 pixelCoordinates){
    return vec2(mix(mapBottomLeft.x, mapTopRight.x, pixelCoordinates.x), mix(mapBottomLeft.y, mapTopRight.y, pixelCoordinates.y));
}

void main()
{
    vec4 score = vec4(0.0, 0.0, 0.0, 0.0);
    
    vec2 pixelCoordinates = vec2(gl_FragCoord.x/screenSize.x, gl_FragCoord.y/screenSize.y);
    
    vec2 latlon = computeCoordinates(pixelCoordinates);
    

    vec2 p = vec2(gl_FragCoord.x*1.0, gl_FragCoord.y*1.0);
    
    vec2 c1 = vec2(0.75*screenWidth, 0.75*screenHeight);
    vec2 c2 = vec2(0.4*screenWidth, 0.6*screenHeight);
    vec2 c3 = vec2(0.7*screenWidth, 0.4*screenHeight);
    
    
    float a = 0.7*gaussian(distance(p, c1)*distance(p, c1), 0.25*screenHeight);
    float b = 0.7*gaussian(distance(p, c2)*distance(p, c2), 60.0);
    float c = 0.7*gaussian(distance(p, c3)*distance(p, c3), 80.0);
    //b= 0.0, c = 0.0;
    float alpha = clamp(a+b+c, 0.0, 1.0);
    
    gl_FragColor = vec4(1, 0, 0, alpha);
    
    if(alpha == 0.0){
        gl_FragColor = vec4(0.0, 0.0, 1.0, 0.0);
    }
}
