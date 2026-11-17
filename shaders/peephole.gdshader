shader_type canvas_item;
uniform float aspect = 1.777778;
uniform float brightness = 1.0;

void fragment() {
	vec2 p = (UV - vec2(0.5)) * vec2(aspect, 1.0);
	float radius = length(p);
	float aperture = 1.0 - smoothstep(0.425, 0.435, radius);
	// Distortion belongs to the optical opening, never the walking camera.
	vec2 warped = p * (1.0 + 0.75 * radius * radius);
	vec2 sample_uv = vec2(0.5) + warped / vec2(aspect, 1.0);
	vec3 image = texture(TEXTURE, clamp(sample_uv, vec2(0.0), vec2(1.0))).rgb;
	float edge = 1.0 - 0.35 * smoothstep(0.25, 0.435, radius);
	COLOR = vec4(image * aperture * edge * brightness, 1.0);
}
