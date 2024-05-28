#version 150

#moj_import <branding.glsl>

in vec2 texCoord0;
in float freezeOverlay;

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
    if (opacity == 0.0) {
        discard;
    }
    if (texelFetch(Sampler0, ivec2(267, 146), 0) == vec4(1)) {
        fragColor = vec4(BRAND_COLOR, opacity);
    } else {
        fragColor = color * modulator;
    }
}