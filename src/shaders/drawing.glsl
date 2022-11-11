#version 300 es
/** Fragment shader for drawing on the simulation texture */

precision mediump float;

in vec2 vTextureCoord;     // Texture coordinates 0.0 to 1.0
uniform highp usampler2D uStates;     // Input states texture
uniform vec2 uSize;             // Size of simulation canvas in pixels
uniform vec3 uMouse;             // Mouse: X, Y, Radius
uniform uint uMouseMask;            // Mouse: Position, radius, uMouseMask
uniform uvec4 uPenState;         // RGBS pen state
out uvec4 fragColor;

#define mMouseDrawing uint(4) /**100*/
#define mDrawValueOr0 uint(2) /**010*/
#define mStateOrPaint uint(1) /**001*/

void main(void) {
    fragColor = texture(uStates, vTextureCoord);

    // Calculate toroidal distance to mouse
    vec2 pixPos = floor(vTextureCoord * uSize);
    float pMouseDist = uMouse.z * 2.0;
    for (int x = -1; x <= 1; x += 1) {
        for (int y = -1; y <= 1; y += 1) {
            pMouseDist = min(pMouseDist, distance(pixPos, (uMouse.xy - vec2(x, y)) * uSize));
        }
    }

    // Mouse click adds cells
    // This is ripe for optimization
    if (bool(uMouseMask & mMouseDrawing) && (floor(pMouseDist) < uMouse.z)) {
        if (bool(uMouseMask & mStateOrPaint)) {
            if (bool(uMouseMask & mDrawValueOr0)) {
                fragColor.a = uPenState.a;
            } else {
                fragColor.a = uint(0);
            }
        } else {
            if (bool(uMouseMask & mDrawValueOr0)) {
                fragColor.rgb = uPenState.rgb;
            } else {
                fragColor.rgb = uvec3(0);
            }
        }
    }
}