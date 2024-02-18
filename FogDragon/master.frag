#version 430 compatibility

in vec2 vST;

uniform sampler2D uTexUnitA;
uniform sampler2D uTexUnitB;
uniform sampler2D uTexUnitC;

uniform float uA;

uniform bool uDisplayLighting;
uniform bool uDisplayDepth;
uniform bool uDisplayFog;

void
main() {
	vec4 depth = texture( uTexUnitA, vST);
	vec4 modelColor = texture( uTexUnitB, vST);
	vec4 fog = texture( uTexUnitC, vST);



	vec4 final = modelColor + depth/uA; 
	// gl_FragColor = modelColor + depth*(depth+uA);


	if (uDisplayLighting) {
		gl_FragColor = modelColor;
	}else if(uDisplayDepth) {
		gl_FragColor = depth;
	}else if(uDisplayFog) {
		gl_FragColor = fog;
	}else{
		gl_FragColor = vec4(sqrt(abs(depth.rgb-fog.rgb)), 1.0);
	}
}