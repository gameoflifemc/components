#version 150

#moj_import <fog.glsl>
#moj_import <colors.glsl>

uniform sampler2D Sampler0;
uniform vec4 ColorModulator;
uniform vec4 FogColor;
uniform float FogStart;
uniform float FogEnd;
uniform float GameTime;

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
    vec3 rgb = color.rgb;
    float r = color.r;
    float g = color.g;
    float b = color.b;
    // task & goal advancement text + tab completer text recolor
    if (rgb == vec3(252.0 / 255.0, 252.0 / 255.0, 0.0)) {
        color = vec4(BRAND_COLOR, opacity);
    } else
    // tab completer shadow recolor
    if (r <= 62.3 / 255.0 && r > 62.2 / 255.0 && g <= 62.3 / 255.0 && g > 62.2 / 255.0 && b == 0.0) {
        color = vec4(BRAND_SHADOW, opacity);
    } else
    // challenge advancement text recolor
    if (r == 252.0 / 255.0 && g <= 134.5 / 255.0 && g > 133.5 / 255.0 && b == 252.0 / 255.0) {
        color = vec4(240.0 / 255.0, 200.0 / 255.0, 0.0, opacity);
    } else
	// remove xp text
	if (depth == 600.0 && (rgb == vec3(0.0, 0.0, 0.0) || (r <= 126.5 / 255.0 && r > 125.5 / 255.0 && g == 252.0 / 255.0 && b <= 32.5 / 255.0 && b > 31.5 / 255.0))) {
		color = vec4(0.0, 0.0, 0.0, 0.0);
	} else
    // icons
    if (opacity > 0.49 && opacity < 0.51) {
        if (mod(depth, 1.0) == 0.0) {
            // remove icon shadows
            discard;
        } else {
            // return full opacity to icons
            color.a = 1.0;
        }
        if (r == 0.0 && g == 0.0 && b >= 21.5 / 255.0 && b <= 36.5 / 255.0) {
            // loading wheel animation
            float c = 1.0 - fract(GameTime * 1200) - 0.125 * (int(b * 255.0) % 20 / 2);
            if (c <= 0.0) {
                c += 1.0;
            }
            c += 0.25;
            color = vec4(c, c, c, 1.0);
        }
    } else
    // transparent icons
    if (opacity > 0.24 && opacity < 0.26) {
        if (mod(depth, 1.0) == 0.0) {
            // remove icon shadows
            discard;
        } else {
            // return half opacity to icons
            color.a = 0.5;
        }
    }
    // compass
    if (r == 0.0 && g == 0.0 && b > 0.5 / 255.0 && b < 20.5 / 255.0) {
        // compass side transparency
        color = vec4(1, 1, 1, b * 255.0 / 28.0);
    }
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}