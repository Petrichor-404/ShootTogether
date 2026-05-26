shader_type canvas_item;


void fragment() {
	vec4 color = texture(TEXTURE,UV + vec2(.08*TIME, .045*TIME));
	COLOR = color;
}
