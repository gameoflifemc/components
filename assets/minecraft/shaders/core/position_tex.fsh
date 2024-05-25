#version 150

#moj_import <branding.glsl>

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;

in vec2 texCoord0;
in float freezeOverlay;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    vec4 modulator = ColorModulator;
    if (freezeOverlay == 1) {
        if (1 - modulator.a > color.a || color.a == 0) {
            discard;
        }
        if (color.a > 1.4 - modulator.a) {
            color.a = 1;
        }
        modulator.a = 1;
    }
    if (color.a == 0.0) {
        discard;
    }
    if (texelFetch(Sampler0, ivec2(267, 146), 0) == vec4(1)) {
        fragColor = vec4(BRAND_COLOR, color.a);
    } else {
        fragColor = color * modulator;
    }
}