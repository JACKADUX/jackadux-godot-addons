shader_type canvas_item;

uniform sampler2D sct : hint_screen_texture;

vec4 difference(vec4 base, vec4 blend){
	return abs(base - blend);
}

void fragment(){
	vec4 color = texture(TEXTURE, UV);
	COLOR.rgb = difference(color, texture(sct, SCREEN_UV)).rgb;
}