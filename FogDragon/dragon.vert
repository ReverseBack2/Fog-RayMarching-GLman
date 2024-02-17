// make this 120 for the mac:
#version 430 compatibility

// Uniform varaibles for wave function

uniform float uA, uB, uC, uD; // amplitude, frequency, Phase shift, decay rate
uniform float uLightX, uLightY, uLightZ;



// out variables to be interpolated in the rasterizer and sent to each fragment shader:

out  vec3  vN;	  		// normal vector
out  vec3  vL;	  		// vector from point to light
out  vec3  vE;	  		// vector from point to eye
out  vec2  vST;	  		// (s,t) texture coordinates
out  vec3 vMCposition;  // (x, y, z) global position

// where the light is:

const vec3 LightPosition = vec3(  uLightX, uLightY, uLightZ );

void
main( )
{
	// change vertex position and normal vectors based on wave equation

	vST = gl_MultiTexCoord0.st;
	vec4 vertex = gl_Vertex;

	float r = length(vertex.xyz);
	

	vN = gl_Normal;  // normal vector


	vec4 ECposition = gl_ModelViewMatrix * vertex;
	vL = LightPosition - ECposition.xyz;	    // vector from the point
												// to the light position
	vE = vec3( 0., 0., 0. ) - ECposition.xyz;	// vector from the point
												// to the eye position
	gl_Position = gl_ModelViewProjectionMatrix * vertex;
	vMCposition = (vertex).xyz;
}
