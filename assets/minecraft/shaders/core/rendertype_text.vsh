#version 150

#moj_import <fog.glsl>

in vec4 Color;
in vec3 Position;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;
uniform float GameTime;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out float depth;
out vec4 vertexColor;
out vec2 texCoord0;

void main() {
	// get depth
    depth = Position.z;
    // add time-dependant offset
    float opacity = Color.a;
    vec4 addend;
    if (depth == 2400.06) {
        float movement = fract(GameTime * 60.0) / 4;
        addend = vec4(0.0, movement, 0.0, 0.0);
    } else {
        addend = vec4(0.0);
    }
	gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0) + addend;
    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
}
