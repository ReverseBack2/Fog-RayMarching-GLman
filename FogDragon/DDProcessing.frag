#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;

void
main() {
	vec4 image = texture( uTexUnitA, vST);
	gl_FragColor = image;
}