shader_type canvas_item;

instance uniform float scale = 1.;
instance uniform vec2 offset = vec2(0,0);

void vertex() {
	VERTEX *= scale;
	VERTEX -= offset;
}
