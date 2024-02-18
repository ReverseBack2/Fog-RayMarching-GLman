#version 430 compatibility


out vec3 camRay;
out vec2 fCoord;



uniform float camAngX, camAngY; 	// range : -2 -> 2


void
main( void )
{
	vec4 V = gl_Vertex;

	

	gl_Position = gl_ModelViewProjectionMatrix * V;

	// Configure the Ray
	vec2 vST = gl_MultiTexCoord0.st;

	fCoord = (vST*2) - 1.0;	//0->1 to 0->2, then -1->1
}
