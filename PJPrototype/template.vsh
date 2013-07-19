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

attribute vec4 position;
void main()
{
	gl_Position = position;
}
