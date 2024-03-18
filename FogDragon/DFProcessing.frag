#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;

uniform bool blur;
uniform float step;

uniform float uRedScale;
uniform float uGreenScale;
uniform float uBlueScale;

uniform float uRedPow;
uniform float uGreenPow;
uniform float uBluePow;


uniform vec4 BLACK = vec4(0.);
uniform float blurCoef[9] = {1., 4., 1., 4., 9., 4., 1., 4., 1.};

void
main() {
	vec4 image = texture( uTexUnitA, vST);
	vec4 samples = BLACK;



	float xSample = -step;
	float ySample = -step;

	for(int i = 0; i < 3; i++) {
		for(int j = 0; j < 3; j++) {
			samples = samples + blurCoef [3*i+j] * texture( uTexUnitA, vec2(vST.s + xSample, vST.t + ySample));
			ySample = ySample + step;
		}
		xSample = xSample + step;
		ySample = -step;
	}

	samples = samples/29.;

	image.r = uRedScale * pow(image.r, uRedPow);
	image.g = uGreenScale * pow(image.g, uGreenPow);
	image.b = uBlueScale * pow(image.b, uBluePow);

	samples.r = uRedScale * pow(samples.r, uRedPow);
	samples.g = uGreenScale * pow(samples.g, uGreenPow);
	samples.b = uBlueScale * pow(samples.b, uBluePow);


	gl_FragColor = image;
	if(blur)
		gl_FragColor.rb = samples.rb;

}