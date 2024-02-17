#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;
uniform sampler2D uTexUnitB;

void
main() {
	vec4 depth = texture( uTexUnitA, vST);
	vec4 modelColor = texture( uTexUnitB, vST);
	// gl_FragColor = modelColor * depth.r; 
	gl_FragColor = modelColor + depth*depth;
}