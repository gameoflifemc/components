#version 150

#moj_import <colors.glsl>

in vec2 texCoord0;
in float freezeOverlay;
in float depth;

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    vec4 modulator = ColorModulator;
    float opacity = color.a;
    if (freezeOverlay == 1) {
        if (1 - modulator.a > opacity || opacity == 0) {
            discard;
        }
        if (opacity > 1.4 - modulator.a) {
            color.a = 1;
        }
        modulator.a = 1;
    }
    float r = color.r;
    // remove empty player heads from TAB list
    if (depth == 2800.0 && r >= 0.332 && r <= 0.334 && color.g >= 0.332 && color.g <= 0.334 && color.b >= 0.332 && color.b <= 0.334) {
        color = vec4(0);
    }
    if (opacity == 0.0) {
        discard;
    }
    if (texelFetch(Sampler0, ivec2(267, 146), 0) == vec4(1)) {
        fragColor = vec4(BRAND_COLOR, opacity);
    } else {
        fragColor = color * modulator;
    }
}