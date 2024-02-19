#version 430 compatibility

in vec2 fCoord;

uniform sampler2D uTexUnitA;
uniform sampler3D Noise3;

uniform float uFogAIntensity;
uniform float uFogCIntensity;
uniform float uFogFreq;
uniform float uFogginess;

uniform bool UseFog2;

uniform float uTimerScale;
uniform float Timer;


const vec2 vST = 0.5*fCoord - vec2(0.5);

float fogGet( vec3 pos ) {
	float time = abs(Timer - 0.5);
	vec4 nv = texture( Noise3, vec3(pos.xy, pos.z+(time*uTimerScale)) * uFogFreq );
	float n = nv.g + nv.g + nv.b + nv.a;    // 1. -> 3.
	n = n - 1.;                             // 0. -> 2.
	n = pow( n, uFogginess);				// apply Fogginess 0 -> 100;
	n = n/pow(2., uFogginess-1.);				// 0. -> 1.0
	// n = n + 0.5;							// 0.25 => 0.75


	return n;
}

vec4 alphaMix( vec4 front, vec4 back ) {
	return mix( vec4(front.rgb, 1.0), back, 1.0-front.w);
}

void
main() {
	vec4 depth = texture( uTexUnitA, vST) * 5.;

	vec4 fog = vec4(0.);
	vec3 fogColor = vec3(0.5, 0.5, 0.5);
	float t = 0.;
	float step = 0.05;
	while ( t <= depth.x ) {
		if (t == 0.){
			fog = alphaMix ( vec4( fogColor * uFogCIntensity, (mod(depth.x, step) - step) * uFogAIntensity * fogGet(vec3( vST, t ) ) ), fog );
		}else{
			fog = alphaMix ( vec4( fogColor * uFogCIntensity, uFogAIntensity * fogGet(vec3( vST, t ) ) ), fog );
		}
		t = t + step;
	}

	vec4 fog2 = vec4(0.);
	for ( int i = 0; i < 10; i++ ) {
		fog2 = alphaMix ( vec4( fogColor * uFogCIntensity, uFogAIntensity * fogGet(vec3( vST, i ) ) ), fog2 );
	}
	// fog2.a = fog2.a*depth.x;
	fog2.a = fog2.a-(0.25/depth.x);
	



	// gl_FragColor = modelColor + depth*(depth+uA);


	//storing the alpha value in B channel because renders full opacity image
	fog.b = fog.a;
	fog2.b = fog2.a;
	if(!UseFog2){
		gl_FragColor = fog;
	}else{
		gl_FragColor = fog2;
	}

	if(depth.x >= 5.)
		gl_FragColor = vec4(fogColor.xy, 1.0, 1.0);
	
}