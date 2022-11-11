#version 300 es
/** Fragment shader that randomizes automata from a seed */
precision mediump float;

uniform vec4 uSeed;        // Number pf subrule indices
uniform uint uStates;

in vec2 vTextureCoord;     // Texture coordinates 0.0 to 1.0

out uvec4 newstate;

float rand(vec2 n) { 
	return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float noise(vec2 p){
	vec2 ip = floor(p);
	vec2 u = fract(p);
	u = u*u*(3.0-2.0*u);
	
	float res = mix(
		mix(rand(ip),rand(ip+vec2(1.0,0.0)),u.x),
		mix(rand(ip+vec2(0.0,1.0)),rand(ip+vec2(1.0,1.0)),u.x),u.y);
	return res*res;
}


void main(void) {
    newstate = uvec4(
        noise(vTextureCoord*1000.0*uSeed.x + uSeed.x)*255.0,
        noise(vTextureCoord*1000.0*uSeed.y + uSeed.y)*255.0,
        noise(vTextureCoord*1000.0*uSeed.z + uSeed.z)*255.0,
        uint(noise(vTextureCoord*1000.0*uSeed.w)*255.0)%uStates
    );
}
