#version 150

#moj_import <fog.glsl>
#moj_import <branding.glsl>

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;
uniform vec4 FogColor;
uniform float FogStart;
uniform float FogEnd;

in float vertexDistance;
in vec4 vertexColor;
in vec3 Position;
in vec2 texCoord0;
in float depth;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0) * vertexColor * ColorModulator;
    float opacity = color.a;
    if (opacity < 0.1) {
        discard;
    }
    float r = color.r;
    float g = color.g;
    float b = color.b;
    // xp text recolor
    if (r <= 126.50 / 255.0 && r > 126.49 / 255.0 && g == 252.0 / 255.0 && b <= 31.63 / 255.0 && b > 31.62 / 255.0) {
        color = vec4(53.0 / 255.0, 228.0 / 255.0, 56.0 / 255.0, opacity);
    }
    // xp text shadow recolor
    if (r <= 31.7 / 255.0 && r > 31.6 / 255.0 && g <= 62.3 / 255.0 && g > 62.25 / 255.0 && b <= 8.0 / 255.0 && b > 7.9 / 255.0) {
        color = vec4(34.0 / 255.0, 64.0 / 255.0, 35.0 / 255.0, opacity);
    }
    // task & goal advancement text + tab completer text recolor
    if (color.rgb == vec3(252.0 / 255.0, 252.0 / 255.0, 0.0)) {
        color = vec4(BRAND_COLOR, opacity);
    }
    // tab completer shadow recolor
    if (r <= 62.3 / 255.0 && r > 62.2 / 255.0 && g <= 62.3 / 255.0 && g > 62.2 / 255.0 && b == 0.0) {
        color = vec4(BRAND_SHADOW, opacity);
    }
    // challenge advancement text recolor
    if (r == 252.0 / 255.0 && g <= 134.5 / 255.0 && g > 133.5 / 255.0 && b == 252.0 / 255.0) {
        color = vec4(240.0 / 255.0, 200.0 / 255.0, 0.0, opacity);
    }
    // icons
    if (opacity > 0.49 && opacity < 0.51) {
        if (mod(depth, 1.0) == 0.0) {
            // remove icon shadows
            discard;
        } else {
            // return full opacity to icons
            color.a = 1.0;
        }
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}