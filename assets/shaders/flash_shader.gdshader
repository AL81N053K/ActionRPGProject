shader_type canvas_item;

uniform bool active = false;
uniform vec3 export_color = vec3(1.0, 1.0, 1.0);

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 color = vec4(export_color.r, export_color.g, export_color.b, previous_color.a);
	vec4 new_color = previous_color;
	if (active == true) {
		new_color = color;
	}
	COLOR = new_color;
}