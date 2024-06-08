#version 150

#moj_import <fog.glsl>

in vec4 Color;
in vec3 Position;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler2;
uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform int FogShape;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;
out float depth;

void main() {
	gl_Position = ProjMat * ModelViewMat * vec4(Position, 1.0);
    vertexDistance = fog_distance(Position, FogShape);
    vertexColor = Color * texelFetch(Sampler2, UV2 / 16, 0);
    texCoord0 = UV0;
	// get depth
    depth = Position.z;
	// remove xp text
	if (depth == 600.0) {
		vertexColor = vec4(0.0, 0.0, 0.0, 0.0);
	}
}
