#version 150

#moj_import <light.glsl>
#moj_import <fade.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;
in vec3 Normal;

uniform sampler2D Sampler2;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform vec3 ChunkOffset;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

float mod289(float x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}
vec4 perm(vec4 x) {
    return mod289(((x * 34.0) + 1.0) * x);
}
float rollRandom(vec3 seed) {
    vec3 a = floor(seed);
    vec3 d = seed - a;
    d = d * d * (3.0 - 2.0 * d);

    vec4 b = a.xxyy + vec4(0.0, 1.0, 0.0, 1.0);
    vec4 k1 = perm(b.xyxy);
    vec4 k2 = perm(k1.xyxy + b.zzww);

    vec4 c = k2 + a.zzzz;
    vec4 k3 = perm(c);
    vec4 k4 = perm(c + 1.0);

    vec4 o1 = fract(k3 * (1.0 / 41.0));
    vec4 o2 = fract(k4 * (1.0 / 41.0));

    vec4 o3 = o2 * d.z + o1 * (1.0 - d.z);
    vec2 o4 = o3.yw * d.x + o3.xz * (1.0 - d.x);

    return o4.y * d.y + o4.x * (1.0 - d.y);
}

void main() {
    // use UV as vertex id order is not guaranteed due to water being double sided with different vertex order on the underside
    vec2 uv = mod(UV0, 16.0/1024.0) * 1024.0/16.0;

    // vanilla calculations
    vertexDistance = length((ModelViewMat * vec4(Position + ChunkOffset, 1.0)).xyz);
    texCoord0 = UV0;

    // combine matrices
    mat4 matrices = ProjMat * ModelViewMat;

    // transform normal
    vec4 normal = matrices * vec4(Normal, 0.0);

    // boolean checks
    int PosX = 0;
    int PosZ = 0;
    int NegX = 0;
    int NegY = 0;
    int NegZ = 0;
    if (Normal == vec3(1.0, 0.0, 0.0)) {
        PosX = 1;
    } else if (Normal == vec3(0.0, 0.0, 1.0)) {
        PosZ = 1;
    } else if (Normal == vec3(-1.0, 0.0, 0.0)) {
        NegX = 1;
    } else if (Normal == vec3(0.0, -1.0, 0.0)) {
        NegY = 1;
    } else if (Normal == vec3(0.0, 0.0, -1.0)) {
        NegZ = 1;
    }

    // uv data
    float uvX = uv.x;
    float uvY = uv.y;

    // uv offset
    vec3 uvOffset = vec3(uvX, 0.0, uvY);
    if (PosX == 1) { // positive X
        uvOffset = vec3(0.0, 1.0 - uvY, 1.0 - uvX);
    } else if (PosZ == 1) { // positive Z
        uvOffset = vec3(uvX, 1.0 - uvY, 0.0);
    } else if (NegX == 1) { // negative X
        uvOffset = vec3(0.0, 1.0 - uvY, uvX);
    } else if (NegY == 1) { // negative Y
        uvOffset = vec3(uvX, 0.0, 1.0 - uvY);
    } else if (NegZ == 1) { // negative Z
        uvOffset = vec3(1.0 - uvX, 1.0 - uvY, 0.0);
    }
    
    // sync random and fade amount between vertices on same face
    float random = rollRandom((Position - uvOffset));
    float fade = max(0.0, length((ModelViewMat * vec4(Position - uvOffset + vec3(0.5) + ChunkOffset, 1.0)).xyz) - FADEDISTANCE);
    fade *= fade;
    
    // animation and scaling
    float anim = (sin(mod((random) * 1600.0, TWOPI)) / 8.0) * 0.25;
    float scale = clamp(fade * (anim + 0.75) * 0.1 / FADESCALE, 0.0, 1.0);

    // uv scaling
    vec3 uvScale = vec3(0.5 - uvX, 0.0, 0.5 - uvY);
    if (PosX == 1) { // positive X
        uvScale = vec3(0.0, uvY - 0.5, uvX - 0.5);
    } else if (PosZ == 1) { // positive Z
        uvScale = vec3(0.5 - uvX, uvY - 0.5, 0.0);
    } else if (NegX == 1) { // negative X
        uvScale = vec3(0.0, uvY - 0.5, 0.5 - uvX);
    } else if (NegY == 1) { // negative Y
        uvScale = vec3(0.5 - uvX, 0.0, uvY - 0.5);
    } else if (NegZ == 1) { // negative Z
        uvScale = vec3(uvX - 0.5, uvY - 0.5, 0.0);
    }
    uvScale *= scale;

    // position with offset
    vec3 posOffset = Position + ChunkOffset;
    // position with scaling
    if (any(notEqual(mod(Position, vec3(1.0)), vec3(0.0)))) {
        // don't floor for non full blocks
        gl_Position = matrices * vec4(posOffset + uvScale, 1.0);
    } else {
        gl_Position = matrices * vec4(floor(Position) + ChunkOffset + uvScale, 1.0);
    }
    // position with offset
    gl_Position += normal * fade * (0.2 / FADESCALE * random + anim * 0.04);

    // apply fade color
    if (fade > 0) {
        vertexColor = vec4((fade + 30) / 75 * FADECOLOR, 1.0);
    } else {
        vertexColor = Color * minecraft_sample_lightmap(Sampler2, UV2);
    }

    // disable visibility when out of range
    if (fade > 15.0 * FADESCALE) {
        gl_Position = vec4(100.0, 100.0, 100.0, -1.0);
    }
}
