shader_type spatial;
render_mode unshaded, blend_mix, cull_disabled, depth_draw_never, fog_disabled;
uniform float strength : hint_range(0.0, 1.0) = 1.0;
uniform vec3 beam_color : source_color = vec3(0.68, 0.82, 0.73);
void fragment() {
	float side = pow(max(sin(UV.x * 3.14159265), 0.0), 0.65);
	float end = smoothstep(0.0, 0.035, UV.y) * pow(max(1.0 - UV.y, 0.0), 1.5);
	ALBEDO = beam_color;
	ALPHA = side * end * strength * 0.022;
}
