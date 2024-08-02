#version 150

#moj_import <fog.glsl>

uniform sampler2D Sampler0;
uniform float FogStart;
uniform float FogEnd;
uniform float GameTime;
uniform vec4 FogColor;
uniform vec4 ColorModulator;

in float vertexDistance;
in vec2 texCoord0;
in vec4 vertexColor;
in vec4 lightMapColor;
in vec4 overlayColor;
flat in int blinking;

out vec4 fragColor;

void main() {
    vec4 color = texture(Sampler0, texCoord0);
    //blinking
    vec2 texSize = textureSize(Sampler0, 0);
    if (blinking == 1 && (texCoord0.y > 0.125 && texCoord0.y < 0.25) && ((texCoord0.x > 0.125 && texCoord0.x < 0.25) || (texCoord0.x > 0.625 && texCoord0.x < 0.75))) {
        // offset texture
        vec4 offsetColor = texture(Sampler0, texCoord0 + vec2(16.0/texSize.x, -8.0/texSize.y));
        //calculate timing
        vec2 duration = vec2(5, 0.2);
        float time = mod(GameTime * 1200, duration.x + duration.y);
        color = (time < duration.y) ? offsetColor : color;
    }
    if (color.a < 0.1) {
        discard;
    }
    color *= vertexColor * ColorModulator;
    color.rgb = mix(overlayColor.rgb, color.rgb, overlayColor.a);
    color *= lightMapColor;
    fragColor = linear_fog(color, vertexDistance, FogStart, FogEnd, FogColor);
}