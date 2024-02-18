#version 430 compatibility

in vec2 fCoord;

uniform sampler2D uTexUnitA;
uniform sampler3D Noise3;

uniform float uA;

uniform bool uDisplayLighting;
uniform bool uDisplayDepth;
uniform bool uDisplayFog;

const vec2 vST = 0.5*fCoord - vec2(0.5);

float fog( vec3 pos ) {
	vec4 nv = texture( Noise3, pos );
	float n = nv.r + nv.g + nv.b + nv.a;    // 1. -> 3.
	n = n - 1.;                             // 0. -> 2.
	n = n/2.;								// 0. -> 1.

	return n;
}

void
main() {
	vec4 depth = texture( uTexUnitA, vST);
	



	// gl_FragColor = modelColor + depth*(depth+uA);


	gl_FragColor = depth;
}