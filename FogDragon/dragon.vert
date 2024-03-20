// make this 120 for the mac:
#version 430 compatibility

// Uniform varaibles for wave function

uniform float uA, uB, uC, uD; // amplitude, frequency, Phase shift, decay rate
uniform float uLightX, uLightY, uLightZ;

uniform float camAngX, camAngY; 	// range : -2 -> 2, and -0.5 -> 0.5
uniform float dragScale;			// range : 0.5 -> 1 -> 5

uniform float uWingScale;
uniform int uWingFreq;

uniform float Timer;


// out variables to be interpolated in the rasterizer and sent to each fragment shader:

out  vec3  vN;	  		// normal vector
out  vec3  vL;	  		// vector from point to light
out  vec3  vE;	  		// vector from point to eye
out  vec2  vST;	  		// (s,t) texture coordinates
out  vec3  vMCposition;  // (x, y, z) global position
out  vec4  vColor;

// where the light is:

const vec3 LightPosition = vec3(  uLightX, uLightY, uLightZ );

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

void
main( )
{
	// change vertex position and normal vectors based on flapping equation

	vST = gl_MultiTexCoord0.st;

	float time = sin(2.*3.14*Timer*float(uWingFreq));

	vec4 vertex = vec4(gl_Vertex.xyz * dragScale, gl_Vertex.w);

	vec4 vert = gl_ModelViewProjectionMatrix * vertex;

	if ((vert.x*vert.x + vert.y*vert.y + vert.z*vert.z) < 25.){
		vertex.y = vertex.y + vertex.x*vertex.x*time*uWingScale;
	}

	
	
	// Dragon Rotaion

	float phi = 3.14*(camAngX+ 2.*Timer);
	float theta = 3.14*camAngY;

	vertex.xyz = rotate3D( vertex.xyz, phi, theta );

	// vertex.w = vertex.w * cos(Timer);


	vN = gl_NormalMatrix * gl_Normal;  // normal vector

	vN.xyz = rotate3D( vN.xyz, phi, theta );


	vec4 ECposition = gl_ModelViewMatrix * vertex;
	vL = LightPosition - ECposition.xyz;	    // vector from the point
												// to the light position
	vE = vec3( 0., 0., 0. ) - ECposition.xyz;	// vector from the point
												// to the eye position
	gl_Position = gl_ModelViewProjectionMatrix * vertex;
	vMCposition = gl_Position.xyz;
}
