shader_type canvas_item;

uniform float h: hint_range(0,1) = 1;
uniform float s: hint_range(0,1) = 1;
uniform float v: hint_range(0,1) = 1;

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	vec3 color = hsv2rgb(vec3(h, UV.x, 1.0-UV.y));
	COLOR.rgb = color;
}
