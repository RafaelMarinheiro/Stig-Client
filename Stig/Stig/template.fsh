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

const float PI = acos(-1.0);

float degToRad(in float deg){
    return (deg*PI)/180.0;
}

float latlonSqDistance(in vec2 latlon1, in vec2 latlon2){
    float earthRadius = 6371.0;
    vec2 dif = vec2(degToRad(latlon2.y-latlon1.y) * cos(degToRad(latlon1.x+latlon2.x)/2.0), degToRad(latlon2.x-latlon1.x));
    return earthRadius * earthRadius * dot(dif, dif);
}

float gaussian(in float sqDist, in float radius){
    float dist = sqDist/(radius*radius);
    return exp(-(dist));
}

vec2 computeCoordinates(in vec2 pixelCoordinates){
    return vec2(mix(mapBottomLeft.x, mapTopRight.x, pixelCoordinates.y), mix(mapBottomLeft.y, mapTopRight.y, pixelCoordinates.x));
}

//"lon": -34.88415,
//"lat": -8.095323

void main()
{
    vec4 score = vec4(0.0, 0.0, 0.0, 0.0);
    vec2 pixelCoordinates = vec2(gl_FragCoord.x/screenSize.x, gl_FragCoord.y/screenSize.y);
    vec2 pixelLatlon = computeCoordinates(pixelCoordinates);
    
    if(pixelLatlon.y < -34.873264){
        gl_FragColor = vec4(1, 0, 0, 0.7);
    } else{
        gl_FragColor = vec4(0, 1, 0, 0.7);
    }
    return;
    
    int menor = -1;
    float distToPixel = 1000.0;
    for(int i = 0; i < placeNumber; i++){
        vec4 placeScore;
        float ndistToPixel = latlonSqDistance(pixelLatlon, latlon[i]);
        if(ndistToPixel < distToPixel){
            distToPixel = ndistToPixel;
            menor = i;
        }
        //Location
        float distToUser = latlonSqDistance(mapPosition, latlon[i]);
        placeScore.x = 0.5*gaussian(distToPixel, 1000.0);
        
        //Social
        placeScore.y = 0.5*gaussian(distToPixel, 1000.0);
        
        //Buzz
        placeScore.z = 0.5*gaussian(distToPixel, 1000.0);
        
        //Overall
        placeScore.w = 0.5*gaussian(distToPixel, 1000.0);
        
        score = score + placeScore;
    }
    
    if(menor == -1){
        gl_FragColor = vec4(0, 0, 0, 0.7);
    } else if(menor == 0){
        gl_FragColor = vec4(1, 0, 0, 0.7);
    } else if(menor == 1){
        gl_FragColor = vec4(0, 1, 0, 0.7);
    } else if(menor == 2){
        gl_FragColor = vec4(0, 0, 1, 0.7);
    }
    return;
    float alpha = clamp(score.x, 0.0, 1.0);
    
    gl_FragColor = vec4(1, 0, 0, alpha);

}
