shader_type canvas_item;
// Full-screen retro pass (docs/ArtBible.md, section 2).
//
// Samples the finished frame on a coarse grid (pixelation), adds per-cell
// grain, reduces colour depth with ordered dithering and darkens the corners.
// It is drawn on a CanvasLayer below the UI, so UI text stays sharp.
// Every effect has a strength uniform so settings can turn it down or off.

uniform sampler2D screen_texture : hint_screen_texture, filter_nearest, repeat_disable;

// Height of the simulated low-resolution image, in pixels.
uniform float vertical_resolution : hint_range(120.0, 1080.0, 1.0) = 300.0;
// Number of steps per colour channel.
uniform float color_levels : hint_range(4.0, 64.0, 1.0) = 20.0;
uniform float dither_strength : hint_range(0.0, 1.0) = 1.0;
uniform float grain_strength : hint_range(0.0, 0.3) = 0.07;
uniform float vignette_strength : hint_range(0.0, 1.0) = 0.45;
// Multiplied into the image; pushes it toward a sickly warm cast.
uniform vec3 tint : source_color = vec3(1.0, 0.96, 0.84);

const float BAYER[16] = float[16](
	0.0, 8.0, 2.0, 10.0,
	12.0, 4.0, 14.0, 6.0,
	3.0, 11.0, 1.0, 9.0,
	15.0, 7.0, 13.0, 5.0
);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
	float scale = max(screen_size.y / vertical_resolution, 1.0);
	vec2 low_res = floor(screen_size / scale);
	vec2 cell = floor(SCREEN_UV * low_res);
	vec2 uv = (cell + 0.5) / low_res;

	vec3 color = texture(screen_texture, uv).rgb * tint;

	// Grain changes 12 times per second, one value per low-res cell.
	float grain = hash(cell + floor(TIME * 12.0) * 17.0) - 0.5;
	color += grain * grain_strength;

	// Ordered dithering before quantising.
	int index = int(mod(cell.y, 4.0)) * 4 + int(mod(cell.x, 4.0));
	float threshold = (BAYER[index] / 16.0 - 0.5) * dither_strength;
	color = floor(color * color_levels + threshold + 0.5) / color_levels;

	vec2 offset = uv - 0.5;
	color *= 1.0 - vignette_strength * dot(offset, offset) * 2.0;

	COLOR = vec4(clamp(color, 0.0, 1.0), 1.0);
}
