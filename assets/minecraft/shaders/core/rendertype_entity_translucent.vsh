#version 150

#moj_import <light.glsl>

in ivec2 UV1;
in ivec2 UV2;
in vec2 UV0;
in vec3 Position;
in vec3 Normal;
in vec4 Color;

uniform sampler2D Sampler0;
uniform sampler2D Sampler1;
uniform sampler2D Sampler2;
uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;

out float vertexDistance;
out vec2 texCoord0;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
flat out int blinking;

void main() {
    vec4 dataPixel = texture(Sampler0, vec2(0.0, 0.0));
    blinking = 0;
    if (dataPixel.a == 1 && dataPixel.rgb == vec3(153.0 / 255.0, 68.0 / 255.0, 1)) {
        blinking = 1;
    }
    gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
}