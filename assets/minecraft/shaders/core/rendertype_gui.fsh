#version 150

#moj_import <colors.glsl>

in vec4 vertexColor;
in vec3 Pos;
in vec3 Pos1;
in vec3 Pos2;
in vec3 Pos3;
in float tooltip;
in float depth;

uniform vec4 ColorModulator;

out vec4 fragColor;

const vec3 edgeColor = vec3(0.0, 15.0 / 255.0, 30.0 / 255.0);
const vec3 fillColor1 = vec3(205.0 / 255.0, 200.0 / 255.0, 235.0 / 255.0);
const vec3 fillColor2 = vec3(175.0 / 255.0, 180.0 / 255.0, 235.0 / 255.0);
const vec3 fillColor3 = vec3(145.0 / 255.0, 170.0 / 255.0, 235.0 / 255.0);
const vec3 fillColor4 = vec3(115.0 / 255.0, 160.0 / 255.0, 235.0 / 255.0);
const vec3 fillColor5 = vec3(85.0 / 255.0, 140.0 / 255.0, 235.0 / 255.0);
const vec3[] left = vec3[](edgeColor, fillColor3, edgeColor);
const vec3[] top = vec3[](edgeColor, fillColor1, edgeColor);
const vec3[] right = vec3[](edgeColor, fillColor3, edgeColor);
const vec3[] bottom = vec3[](edgeColor,  fillColor5, edgeColor);
const vec3[] topleft = vec3[](edgeColor, edgeColor, edgeColor, edgeColor, fillColor1, fillColor1, edgeColor, fillColor2, edgeColor);
const vec3[] topright = vec3[](edgeColor, edgeColor, edgeColor, fillColor1, fillColor1, edgeColor, edgeColor, fillColor2, edgeColor);
const vec3[] bottomleft = vec3[](edgeColor, fillColor4, edgeColor, edgeColor, fillColor5, fillColor5, edgeColor, edgeColor, edgeColor);
const vec3[] bottomright = vec3[](edgeColor, fillColor4, edgeColor, fillColor5, fillColor5, edgeColor, edgeColor, edgeColor, edgeColor);

void main() {
    vec4 color = vertexColor;
    vec2 position1 = Pos1.xy / Pos1.z;
    vec2 position2 = Pos2.xy / Pos2.z;
    vec2 position3 = Pos3.xy / Pos3.z;
    vec2 pmax = max(max(position1, position2), position3);
    vec2 pmin = min(min(position1, position2), position3);
    vec2 size = vec2(pmax - pmin);
    float opacity = color.a;
    // convert white to signature color
    if (color.rgb == vec3(1)) {
        if (depth == 2800.0) {
            color = vec4(BRAND_SHADOW, 0.5);
        } else {
            color = vec4(BRAND_COLOR, opacity);
        }
    } else if (color.rgb == vec3(0)) {
        if (depth == 2800.0 || depth == 2600.0) {
            color = vec4(0);
        }
    } else if (color.rgb == vec3(208.0 / 255)) {
        color = vec4(BRAND_COLOR, 0.5);
    }
    // nicer tooltips
    if (tooltip == 1.0) {
        if (all(greaterThan(size, vec2(1000)))) {
            discard;
            return;
        }
        ivec3 sizes = ivec3(1, 1, 3);
        ivec2 side = ivec2(clamp(abs(pmin - Pos.xy) - (size / 2) + (sizes.xy / 2), ivec2(0), sizes.xy -  1));
        ivec4 corner = ivec4(abs(vec4(pmin, pmax) - Pos.xyxy));
        ivec4 edge = ivec4(lessThan(corner, ivec4(sizes.z, sizes.z, sizes.z, sizes.z)));
        int i = 0;
        switch ((edge.x << 0) + (edge.y << 1) + (edge.z << 2) + (edge.w << 3)) {
            case 1: {
                i = (corner.x) + (side.y) * sizes.z;
                color = vec4(left[i], opacity);
                break;
            }
            case 2: {
                i = (side.x) + (corner.y) * sizes.x;
                color = vec4(top[i], opacity);
                break;
            }
            case 4: {
                i = (sizes.z - corner.z - 1) + (side.y) * sizes.z;
                color = vec4(right[i], opacity);
                break;
            }
            case 8: {
                i = (side.x) + (sizes.z - corner.w - 1) * sizes.x;
                color = vec4(bottom[i], opacity);
                break;
            }
            case 3: {
                i = (corner.x) + (corner.y) * sizes.z;
                color = vec4(topleft[i], opacity);
                break;
            }
            case 6: {
                i = (sizes.z - corner.z - 1) + (corner.y) * sizes.z;
                color = vec4(topright[i], opacity);
                break;
            }
            case 9: {
                i = (corner.x) + (sizes.z - corner.w - 1) * sizes.z;
                color = vec4(bottomleft[i], opacity);
                break;
            }
            case 12: {
                i = (sizes.z - corner.z - 1) + (sizes.z - corner.w - 1) * sizes.z;
                color = vec4(bottomright[i], opacity);
                break;
            }
            default: {
                color = vec4(0.0, 25.0 / 255.0, 65.0 / 255.0, opacity);
            }
        }
    }
    if (opacity == 0.0) {
        discard;
    }
    fragColor = color * ColorModulator;
}