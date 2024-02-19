// make this 120 for the mac:
#version 430 compatibility

// lighting uniform variables -- these can be set once and left alone:
uniform float   uKa = 0.1; //(0.1)	 // coefficients of each type of lighting -- make sum to 1.0
uniform float 	uKd = 0.6; //(0.6)
uniform float 	uKs = 0.4; //(0.4)
uniform vec4    uColor;		 // object color
uniform vec4    uLightColor;		 // object color
uniform vec4    uSpecularColor;	 // light color
uniform float   uShininess = 10;	 // specular exponent


uniform sampler3D 	Noise3;
uniform float 		uNoiseFreq, uNoiseAmp;
uniform float 		Timer;


// in variables from the vertex shader and interpolated in the rasterizer:

in  vec3  vN;		   // normal vector
in  vec3  vL;		   // vector from point to light
in  vec3  vE;		   // vector from point to eye
in  vec2  vST;		   // (s,t) texture coordinates
in 	vec3  vMCposition;   // (x, y, z) global position

vec3
RotateNormal( float angx, float angy, vec3 n )
{
        float cx = cos( angx );
        float sx = sin( angx );
        float cy = cos( angy );
        float sy = sin( angy );

        // rotate about x:
        float yp =  n.y*cx - n.z*sx;    // y'
        n.z      =  n.y*sx + n.z*cx;    // z'
        n.y      =  yp;
        // n.x      =  n.x;

        // rotate about y:
        float xp =  n.x*cy + n.z*sy;    // x'
        n.z      = -n.x*sy + n.z*cy;    // z'
        n.x      =  xp;
        // n.y      =  n.y;

        return normalize( n );
}


void
main( )
{
	vec3 vMC = vMCposition;

	

	vec3 myColor = uColor.rgb;
	vec3 lightColor = uLightColor.rgb;


	// apply the per-fragmewnt lighting to myColor:

	vec3 Normal = normalize(vN);
	vec3 Light  = normalize(vL);
	vec3 Eye    = normalize(vE);

	vec3 ambient = uKa * myColor;

	float dd = max( dot(Normal,Light), 0. );       // only do diffuse if the light can see the point
	vec3 diffuse = uKd * dd * lightColor;

	float ss = 0.;
	if( dot(Normal,Light) > 0. )	      // only do specular if the light can see the point
	{
		vec3 ref = normalize(  reflect( -Light, Normal )  );
		ss = pow( max( dot(Eye,ref),0. ), uShininess );
	}
	vec3 specular = uKs * ss * uSpecularColor.rgb;
	gl_FragColor = vec4( ambient + diffuse + specular,  1. );
}

