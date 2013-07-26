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

attribute vec4 position;
void main()
{
	gl_Position = position;
}
