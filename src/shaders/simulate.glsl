#version 300 es
/** Fragment shader that simulates multistate totalistic cellular automata */

#define NEW_COLOR_BIAS 5

precision mediump float;

uniform highp usampler2D uStates;      // Input states texture
uniform highp usampler2D uRule;        // The cellular automata rule
uniform highp usampler2D uBinomial;    // Pre-computed binomial coefficents (n and k up to 32)




uniform vec2 uSize;             // Size of simulation canvas in pixels
uniform int uNumStates;            // Number of states in this rule (MAX 14)
uniform int uSubIndices;        // Number pf subrule indices

in vec2 vTextureCoord;     // Texture coordinates 0.0 to 1.0

out uvec4 newstate;

// Returns binomial coefficient (n choose k) from precompute texture
int binomial(int n, int k) {
    return int(texelFetch(uBinomial, ivec2(n, k), 0).r);
}

void main(void) {
    // Texel coordinate
    ivec2 pTexCoord = ivec2(vTextureCoord.xy * uSize.xy);

    int curstate = int(texture(uStates, vTextureCoord).a);

    // Counts of each neighbor type
    int nCounts[14] = int[](0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    nCounts[curstate] = -1;

    // Determine neighbor counts
    for (int x = -1; x <= 1; x += 1) {
        for (int y = -1; y <= 1; y += 1) {
            uint v = texture(uStates, vTextureCoord + (vec2(x, y) / uSize)).a;
            nCounts[v] += 1;
        }
    }

    // Determine the 1D index into the rule texture
    int subIndex = 0;
    int y = 8;
    for (int i = 1; i < 14; i++) {
        int v = nCounts[i];
        if (v > 0) {
            int x = uNumStates - i;
            subIndex += binomial(y + x, x) - binomial(y - v + x, x);
        }
        y -= v;
    }
    // Compute final rule index given current state and neighbor states
    int ruleIndex = curstate * uSubIndices + subIndex;
    // Convert 1D rule index into 2D coordinate into rule texture
    newstate.a = uint(texelFetch(uRule, ivec2(ruleIndex % 1024, ruleIndex / 1024), 0).r);

    if (newstate.a != uint(curstate)){
        highp int matchingNeighbors = 1;
        vec3 matchingNeighborsColorSum = vec3(texture(uStates, vTextureCoord).rgb);
        for (int x = -1; x <= 1; x += 1) {
            for (int y = -1; y <= 1; y += 1) {
                if (newstate.a == texture(uStates, vTextureCoord + (vec2(x, y) / uSize)).a) {
                    matchingNeighbors += NEW_COLOR_BIAS;
                    matchingNeighborsColorSum += vec3(texture(uStates, vTextureCoord + (vec2(x, y) / uSize)).rgb) * float(NEW_COLOR_BIAS);
                }
            }
        }

        newstate.rgb = uvec3(round(matchingNeighborsColorSum / float(matchingNeighbors)));
    } else {
        newstate.rgb = texture(uStates, vTextureCoord).rgb;
    }


}