#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;
uniform sampler2D uTexUnitB;
uniform sampler2D uTexUnitC;

uniform sampler2D uTexUnitA2;
uniform sampler2D uTexUnitB2;
uniform sampler2D uTexUnitC2;

uniform float uA;

uniform float fogProcessing;

uniform bool uDisplayLighting;
uniform bool uDisplayDepth;
uniform bool uDisplayFog;

uniform bool uDisplayLighting2;
uniform bool uDisplayDepth2;
uniform bool uDisplayFog2;

vec4 alphaMix( vec4 front, vec4 back ) {
	return mix( vec4(front.rgb, 1.0), back, 1.0-front.w);
}

void
main() {
	vec4 depth = texture( uTexUnitA, vST);
	vec4 modelColor = texture( uTexUnitB, vST);
	vec4 fog = texture( uTexUnitC, vST);

	vec4 depth2 = texture( uTexUnitA2, vST);
	vec4 modelColor2 = texture( uTexUnitB2, vST);
	vec4 fog2 = texture( uTexUnitC2, vST);

	fog.a = fog.g;
	fog.g = fog.r;

	fog2.a = fog2.g;
	fog2.g = fog2.r;



	vec4 final = modelColor + depth/uA; 
	// gl_FragColor = modelColor + depth*(depth+uA);

	vec4 f_fog = mix( fog, fog2, fogProcessing);


	if (uDisplayLighting) {
		gl_FragColor = modelColor;
	}else if(uDisplayDepth) {
		gl_FragColor = depth;
	}else if(uDisplayFog) {
		gl_FragColor = fog;
	}else if(uDisplayLighting2) {
		gl_FragColor = modelColor2;
	}else if(uDisplayDepth2) {
		gl_FragColor = depth2;
	}else if(uDisplayFog2) {
		gl_FragColor = fog2;
	}else{
		gl_FragColor = alphaMix(f_fog, modelColor2);
	}
}