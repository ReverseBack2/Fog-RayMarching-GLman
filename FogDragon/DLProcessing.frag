#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;
uniform float uRedScale;
uniform float uGreenScale;
uniform float uBlueScale;

uniform float uRedPow;
uniform float uGreenPow;
uniform float uBluePow;

void
main() {
	vec4 image = texture( uTexUnitA, vST);
	image.r = uRedScale * pow(image.r, uRedPow);
	image.g = uGreenScale * pow(image.g, uGreenPow);
	image.b = uBlueScale * pow(image.b, uBluePow);
	gl_FragColor = image;
}