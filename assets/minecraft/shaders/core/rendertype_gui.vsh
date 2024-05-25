#version 150

const vec2[] corners = vec2[](vec2(1, 1), vec2(1, -1), vec2(-1, -1), vec2(-1, 1));

in vec4 Color;
in vec3 Position;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform float Scale;

out vec4 vertexColor;
out vec3 Pos;
out vec3 Pos1;
out vec3 Pos2;
out vec3 Pos3;
out float tooltip;

void main() {
    Pos = Position;
    float depth = Position.z;
    int corner = gl_VertexID % 4;
    tooltip = 0.0;
    if (depth == 400 && ProjMat[2][3] == 0) {
        tooltip = 1.0;
        Pos.xy += Scale * corners[corner];
        if (gl_VertexID / 4 != 2) {
            Pos = vec3(0);
        }
    }
    gl_Position = ProjMat * ModelViewMat * vec4(Pos, 1);
    Pos1 = Pos2 = Pos3 = vec3(0);
    switch (corner) {
        case 0: {
            Pos1 = vec3(Pos.xy, 1);
            break;
        }
        case 1: {
            Pos2 = vec3(Pos.xy, 1);
            break;
        }
        case 2: {
            Pos3 = vec3(Pos.xy, 1);
            break;
        }
    }
    vertexColor = Color;
    float opacity = vertexColor.a;
    if (vertexColor.rgb == vec3(0)) {
        if (depth == 2000) {
            // remove scoreboard background
            if (opacity == 0.2980392426 || opacity == 0.4) {
                vertexColor.a = 0;
            }
        } else if (depth == 200 && opacity > 0) {
            // strengthen advancement blur
            vertexColor.a += 0.5;
        }
    }
}