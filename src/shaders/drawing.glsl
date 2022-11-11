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

#define mRGBNotState uvec4(255,255,255,0)

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
        // uPenState is the state which the pen is expressing.
        // We might want to draw that value, or we might want to draw 0's.
        // Without any conditional jumps, compute `penStateOr0`.
        // Expect the compiler to be attentive, so keep everything readable.
        uint drawValueOr0 = (uMouseMask & mDrawValueOr0)>>1; // RShift because this bit is stored in the 2s place.
        uint drawValueOr0Mask = 0u - drawValueOr0;           // Convert 0b1 into 0b11111111 and 0b0 stays 0b0
        uvec4 penStateOr0 = uPenState & drawValueOr0Mask;    // Update the state we will be assigning

        uint drawStateOrPaint = (uMouseMask & mStateOrPaint); // No RShift, this bit is stored in the 1s place
        uint drawStateOrPaintMask = 0u - drawStateOrPaint;    // Convert 0b1 into 0b11111111 and 0b0 stays 0b0
        uvec4 updateMask = mRGBNotState ^ drawStateOrPaintMask;       // Mask of bits, high were we want to provide a new value

        fragColor = (penStateOr0&updateMask)|(fragColor&~updateMask);
    }
}