shader_type canvas_item;

uniform float alpha = 1.0;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	float avg = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
	COLOR.rgb = vec3(avg);
	COLOR.a = alpha;
}