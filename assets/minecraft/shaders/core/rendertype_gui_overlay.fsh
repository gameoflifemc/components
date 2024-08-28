#version 150

in vec4 vertexColor;

uniform vec4 ColorModulator;
uniform mat4 ProjMat;

out vec4 fragColor;

void main() {
    vec4 color = vertexColor;
    if (color.a == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
    if (color.r == 239.0 / 255.0) {
        fragColor = vec4(0.0, 0.0, 0.0, color.a);
    }
}