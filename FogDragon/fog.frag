#version 430 compatibility

in vec2 fCoord;

uniform sampler2D uTexUnitA;
uniform sampler3D Noise3;

uniform float uFogAIntensity;
uniform float uFogCIntensity;
uniform float uFogFreq;
uniform float uFogginess;
uniform float uFogClip;
uniform float uA;
uniform float uB;

uniform float uFCr, uFCb;
uniform float uFCrO, uFCbO;
uniform float uFogP, uFogS, uYcut;

uniform float coX, coY, coZ;
uniform bool testX, testY, testZ;

uniform vec3 fogColor = vec3 (0.5, 0.5, 0.5);

uniform bool UseFog2;

uniform float uTimerScale;
uniform float Timer;

uniform bool customNoise;
uniform bool test;
uniform float SqNoiseScale;
uniform sampler3D NoiseTexUnit;
uniform sampler3D NoiseTexUnit2;


const vec2 vST = 0.5*fCoord - vec2(0.5);

vec3 rotate3D( vec3 ray, float phi, float theta) {
	float z = ray.z;
	float x = ray.x;

	ray.z = z*cos(phi) - x*sin(phi);
	ray.x = z*sin(phi) + x*cos(phi);

	float y = ray.y;
	z = ray.z;

	ray.y = y*cos(theta) - z*sin(theta);
	ray.z = y*sin(theta) + z*cos(theta);

	return ray;
}

vec3 invRotate3D( vec3 ray, float phi, float theta) {
	float z = ray.z;
	float x = ray.x;
	float y = ray.y;


	ray.y = y*cos(theta) - z*sin(theta);
	ray.z = y*sin(theta) + z*cos(theta);

	z = ray.z;

	ray.z = z*cos(phi) - x*sin(phi);
	ray.x = z*sin(phi) + x*cos(phi);

	return ray;
}


float fogGet( vec3 pos ) {
	float time = sin(Timer*1.*3.14);
	time = time * time;

	vec4 nv, nv2;
	float n;

	nv = texture( Noise3, vec3(pos.xy, pos.z+(time*uTimerScale)) * uFogFreq );
	n = nv.g + nv.g + nv.b + nv.a;    // 1. -> 3.
	n = n - 1.;                             // 0. -> 2.

	if(customNoise) {
		nv = texture( NoiseTexUnit, vec3(pos.xy, pos.z+(2.*time*uTimerScale)) * uFogFreq );
		n = n - nv.r * SqNoiseScale;
	}

	n = pow( n, uFogginess);				// apply Fogginess 0 -> 100;
	n = n/pow(2., uFogginess-1.);				// 0. -> 1.0
	// n = n + 0.5;							// 0.25 => 0.75
	
	if((pos.y > uYcut))
		n = n - pow(uFogS*(pos.y-uYcut), uFogP);

	if((pos.x > 0.25 || pos.x < -0.25) && testX)
		return 0.;

	if((pos.y > 0.25 || pos.y < -0.25) && testY)
		return 0.;

	if((pos.z > 0.25 || pos.z < -0.25) && testZ)
		return 0.;

	if (n < uFogClip)
		return 0.;

	if (n < 0.)
		return 0.;

	if ((pos.x*pos.x + pos.y*pos.y + pos.z*pos.z) > 36){
		return 1./uFogAIntensity;
	}

	return n;
}

vec3 getFogColor( vec3 pos) {
	vec3 fColor = fogColor;
	float time = sin(Timer*2.*3.14);
	time = time * time;

	// pos.x = pos.x - uA;
	vec4 nv = texture( NoiseTexUnit, vec3(pos.xy, pos.z+(time*uTimerScale)) * uFogFreq );
	fColor.b = smoothstep(1., 0., (0.-uFCbO-pos.y)*uFCb);
	fColor.r = smoothstep(1., 0., (0.-uFCrO-pos.y)*uFCr);

	// float s = sqrt(pos.z*pos.z + pos.x*pos.x);

	// if( mod(pos.x/pos.z, 0.2) < 0.1 && pos.z > uB )
	// 	//fColor.rb = pos.xy;

		

	return fColor;
}

vec4 alphaMix( vec4 front, vec4 back ) {
	return mix( vec4(front.rgb, 1.0), back, 1.0-front.w);
}

void
main() {
	vec4 depth = texture( uTexUnitA, vST) * 20.;

	vec4 fog = vec4(0.);
	vec3 camPos = vec3( 0., 0., -3.);
	camPos = camPos + vec3( coX, coY, coZ );

	// Scene Rotation angles
	float phi = 3.14*((0.122)+ 2.*Timer); 	// Cam Angle X
	float theta = 3.14*(0.079);				// Cam Angle Y
	

	//normal ray out from camera
	vec3 pos = normalize(vec3(fCoord, 1.732));
	// vec3 pos = normalize(vec3(vST, 1.));
	pos = invRotate3D( pos, phi, theta );
	camPos = rotate3D ( camPos, phi, theta );

	
	float step = 0.025;
	float t = depth.x - mod(depth.x, step);

	while ( t >= 0 ) {
		if (t + step >= depth.x ){
			fog = alphaMix ( vec4( getFogColor(t*pos) * uFogCIntensity, ( (mod(depth.x, step) / step) ) * uFogAIntensity * fogGet(camPos + pos*t) ), fog );
		}else{
			fog = alphaMix ( vec4( getFogColor(t*pos) * uFogCIntensity, uFogAIntensity * fogGet(camPos + pos*t) ), fog );
		}
		t = t - step;
	}

	vec4 fog2 = vec4(0.);
	for ( int i = 0; i < 10; i++ ) {
		fog2 = alphaMix ( vec4( getFogColor(t*pos) * uFogCIntensity, uFogAIntensity * fogGet(pos*t) ), fog2 );
	}
	// fog2.a = fog2.a*depth.x;
	fog2.a = fog2.a-(0.25/depth.x);
	



	// gl_FragColor = modelColor + depth*(depth+uA);


	//storing the alpha value in G channel because renders full opacity image
	fog.g = fog.a;
	fog2.g = fog2.a;
	if(!UseFog2){
		gl_FragColor = fog;
	}else{
		gl_FragColor = fog2;
	}

	// if(depth.x >= 5.)
	// 	gl_FragColor = vec4(fogColor.xy * uFogCIntensity, 1.0, 1.0);

	
}