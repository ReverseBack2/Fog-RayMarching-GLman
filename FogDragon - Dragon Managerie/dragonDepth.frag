// make this 120 for the mac:
#version 430 compatibility


// in variables from the vertex shader and interpolated in the rasterizer:

in  vec3  vE;		   // vector from point to eye


void
main( )
{
	float depth = 0.2 * length(vE);
	gl_FragColor = vec4( depth, depth, depth,  1. );
}

