#version 150

#moj_import <light.glsl>
#moj_import <fade.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV1;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler1;
uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 Light0_Direction;
uniform vec3 Light1_Direction;

out float vertexDistance;
out vec4 vertexColor;
out vec4 lightMapColor;
out vec4 overlayColor;
out vec2 texCoord0;

void main() {
    // vanilla calculations
    mat4 matrices = ProjMat * ModelViewMat;
    gl_Position = matrices * vec4(Position, 1.0);
    vec4 vanillaColor = minecraft_mix_light(Light0_Direction, Light1_Direction, Normal, Color);
    vertexDistance = length((ModelViewMat * vec4(Position, 1.0)).xyz);
    lightMapColor = texelFetch(Sampler2, UV2 / 16, 0);
    overlayColor = texelFetch(Sampler1, UV1, 0);
    texCoord0 = UV0;
    // fade
    float fade = max(0.0, vertexDistance - FADEDISTANCE);
    fade *= fade;
    // animation and scaling
    float anim = (sin(mod(1600.0, TWOPI)) / 8.0) * 0.25;
    float scale = clamp(fade * (anim + 0.75) * 0.1 / FADESCALE, 0.0, 1.0);
    // skip inventory items
    if (ProjMat[3][2] / (ProjMat[2][2] + 1) >= 0.0) {
        // position with offset
        gl_Position += matrices * vec4(Normal, 0.0) * fade * (0.1 / FADESCALE + anim * 0.04);

        // disable visibility when out of range
        if (fade > 15.0 * FADESCALE) {
            gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
        }
        // apply fade color
        if (fade > 0) {
        vertexColor = vec4((fade + 30) / 75 * FADECOLOR, 1.0);
        } else {
            vertexColor = vanillaColor;
        }
    } else {
        vertexColor = vanillaColor;
    }
}
