shader_type canvas_item;

uniform float ant_length = 1.0;
uniform float ant_speed = 1.0;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_scale : hint_range(0, 20) = 1.2;

bool is_outside(vec2 p) {
	return (0. > p.x || p.x > 1.) || (0. > p.y || p.y > 1.);
}

bool is_any_outside(vec2 uv, vec2 size) {
	return is_outside(uv + vec2(-size.x, 0)) ||
			is_outside(uv + vec2(0, size.y)) ||
			is_outside(uv + vec2(size.x, 0)) ||
			is_outside(uv + vec2(0, -size.y)) ||
			is_outside(uv + vec2(-size.x, size.y)) ||
			is_outside(uv + vec2(size.x, size.y)) ||
			is_outside(uv + vec2(-size.x, -size.y)) ||
			is_outside(uv + vec2(size.x, -size.y)) ;
}

void fragment() {
	//COLOR.rgb = line_color.rgb;

	vec2 size = TEXTURE_PIXEL_SIZE * line_scale;
	vec4 color = texture(TEXTURE, UV);

	float outline = 1.;
	if (is_any_outside(UV, size))  // 必须要这样 否则边缘的像素会丢失
	{
		outline = 0.;
	} else {
		outline *= texture(TEXTURE, UV + vec2(-size.x, 0)).a;
		outline *= texture(TEXTURE, UV + vec2(0, size.y)).a;
		outline *= texture(TEXTURE, UV + vec2(size.x, 0)).a;
		outline *= texture(TEXTURE, UV + vec2(0, -size.y)).a;
		outline *= texture(TEXTURE, UV + vec2(-size.x, size.y)).a;
		outline *= texture(TEXTURE, UV + vec2(size.x, size.y)).a;
		outline *= texture(TEXTURE, UV + vec2(-size.x, -size.y)).a;
		outline *= texture(TEXTURE, UV + vec2(size.x, -size.y)).a;
		outline = ceil(min(outline, 1.0));
	}

	vec2 dir = normalize(vec2(1.,1.));
	float r = dot(dir, UV);
	float a = fract(r*length(1./TEXTURE_PIXEL_SIZE)/ant_length-TIME*ant_speed);
	COLOR.rgb = vec3(step(0.5, a));
	COLOR.a = ceil(color.a) - outline;
}