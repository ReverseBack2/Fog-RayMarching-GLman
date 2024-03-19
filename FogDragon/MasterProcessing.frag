#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;
uniform float uRedScale;
uniform float uGreenScale;
uniform float uBlueScale;

uniform float uRedPow;
uniform float uGreenPow;
uniform float uBluePow;

uniform float PixW;

void
main() {

	vec2 st = vST;	
	// Snap ST to grid for mosaic effect
    int numins = int(st.s / PixW);        // same as with the ellipses
    int numint = int(st.t / PixW);        // same as with the ellipses
    float sc = float(numins)*PixW + PixW*0.5;          // same as with the ellipses
    float tc = float(numint)*PixW + PixW*0.5;          // same as with the ellipses
    // for this block of pixels, we are only going to sample the texture at the center:
    st.s = sc;
    st.t = tc;

	vec4 image = texture( uTexUnitA, st);
	image.r = uRedScale * pow(image.r, uRedPow);
	image.g = uGreenScale * pow(image.g, uGreenPow);
	image.b = uBlueScale * pow(image.b, uBluePow);
	gl_FragColor = image;
}