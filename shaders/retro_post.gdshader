shader_type canvas_item;
// Full-screen grade for the walkable 3D corridors (HOUSE-ATMOS-001).
//
// Drawn on a CanvasLayer below the UI and below the 2D room views, so it only
// touches the 3D house and never the text. Every effect has a strength
// uniform so settings can turn it down or off.
//
// What it does, in order:
//   1. Ink: dark outlines where brightness changes sharply, so the 3D corridor
//      reads in the same drawn manner as the painted rooms.
//   2. Grade: maps brightness onto a sick green-to-pale-yellow ramp and blends
//      it over the real colours, so the whole house shares one oppressive tint
//      while reds and creams still read faintly.
//   3. Crush: deep shadows sink toward near-black.
//   4. A heavy oval vignette and cinema bars, as if seen through a lens.
//   5. Fine animated grain.
// No pixelation (docs/DecisionLog.md, K-013): the old pixel and colour-step
// uniforms are kept only so existing settings still bind, and default to off.

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap, repeat_disable;

// Legacy controls, off by default.
uniform float vertical_resolution : hint_range(120.0, 4320.0, 1.0) = 4320.0;
uniform float color_levels : hint_range(4.0, 256.0, 1.0) = 255.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec3 tint : source_color = vec3(1.0, 1.0, 1.0);
uniform float brightness : hint_range(0.7, 1.6) = 1.0;

uniform float grade_strength : hint_range(0.0, 1.0) = 0.0;
uniform vec3 grade_shadow : source_color = vec3(0.03, 0.05, 0.04);
uniform vec3 grade_mid : source_color = vec3(0.34, 0.42, 0.33);
uniform vec3 grade_light : source_color = vec3(0.92, 0.93, 0.80);
uniform float crush : hint_range(0.0, 1.0) = 0.0;
uniform float ink_strength : hint_range(0.0, 1.0) = 0.07;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.34;
// Fraction of the screen height covered by each black bar.
uniform float letterbox : hint_range(0.0, 0.2) = 0.0;
uniform float grain_strength : hint_range(0.0, 0.3) = 0.002;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float luma(vec3 c) {
	return dot(c, vec3(0.299, 0.587, 0.114));
}

void fragment() {
	vec2 px = SCREEN_PIXEL_SIZE;
	vec2 uv = SCREEN_UV;
	vec3 color = texture(screen_texture, uv).rgb * tint;

	// 1. Ink outlines from a Sobel filter on brightness, measured a little wider
	// than one pixel so fine texture noise does not turn into scribble.
	vec2 o = px * 1.5;
	float tl = luma(texture(screen_texture, uv + vec2(-o.x, -o.y)).rgb);
	float tc = luma(texture(screen_texture, uv + vec2(0.0, -o.y)).rgb);
	float tr = luma(texture(screen_texture, uv + vec2(o.x, -o.y)).rgb);
	float ml = luma(texture(screen_texture, uv + vec2(-o.x, 0.0)).rgb);
	float mr = luma(texture(screen_texture, uv + vec2(o.x, 0.0)).rgb);
	float bl = luma(texture(screen_texture, uv + vec2(-o.x, o.y)).rgb);
	float bc = luma(texture(screen_texture, uv + vec2(0.0, o.y)).rgb);
	float br = luma(texture(screen_texture, uv + vec2(o.x, o.y)).rgb);
	float gx = (tr + 2.0 * mr + br) - (tl + 2.0 * ml + bl);
	float gy = (bl + 2.0 * bc + br) - (tl + 2.0 * tc + tr);
	float edge = sqrt(gx * gx + gy * gy);
	// Relative to local brightness, so dark corners still get their lines.
	float relative = edge / (luma(color) + 0.12);
	color *= 1.0 - ink_strength * smoothstep(0.35, 0.9, relative);

	// 2. Grade onto the green ramp.
	float l = clamp(luma(color) * 1.15, 0.0, 1.0);
	vec3 ramp = l < 0.45
		? mix(grade_shadow, grade_mid, l / 0.45)
		: mix(grade_mid, grade_light, (l - 0.45) / 0.55);
	color = mix(color, ramp, grade_strength);

	// 3. Crush the deep shadows.
	color *= mix(1.0, smoothstep(0.0, 0.22, luma(color)), crush);

	// 4. Oval vignette, wider than tall, falling to near-black.
	vec2 v = (uv - 0.5) * vec2(1.0, 1.25);
	float fall = smoothstep(0.30, 0.78, length(v));
	color *= 1.0 - vignette_strength * fall;

	// 5. Grain, changing a dozen times a second.
	vec2 cell = floor(uv / px);
	color += (hash(cell + floor(TIME * 12.0) * 17.0) - 0.5) * grain_strength;

	// Legacy colour stepping (off unless a setting turns it on).
	color = floor(color * color_levels + 0.5) / color_levels;

	// Cinema bars.
	if (uv.y < letterbox || uv.y > 1.0 - letterbox) {
		color = vec3(0.0);
	}
	COLOR = vec4(clamp(color * brightness, 0.0, 1.0), 1.0);
}
