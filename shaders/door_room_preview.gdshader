shader_type spatial;
render_mode unshaded, cull_disabled, fog_disabled;
uniform sampler2D room_image : source_color, filter_linear;
uniform vec4 room_tint : source_color = vec4(1.0);
void fragment() {
	ALBEDO = texture(room_image, SCREEN_UV).rgb * room_tint.rgb;
}
