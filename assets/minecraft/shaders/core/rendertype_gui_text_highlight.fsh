#version 150

#moj_import <colors.glsl>

in vec4 vertexColor;

uniform vec4 ColorModulator;

out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    color = vec4(BRAND_COLOR, color.a);
    fragColor = color * ColorModulator;
}
