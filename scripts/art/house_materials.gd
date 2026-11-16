class_name HouseMaterials
extends RefCounted
## Shared materials for the house, with textures generated in code.
##
## These are stand-ins that set the visual direction (docs/ArtBible.md,
## section 2: dirty, stifling, uncanny). Any of them can later be replaced by
## a painted texture without touching the code that uses the material.
##
## Surface materials use world-space triplanar mapping so box geometry needs
## no UV work; furniture materials use local triplanar mapping so the pattern
## moves with the object.

const WALL_TILE_METRES: float = HouseLayout.STOREY_HEIGHT

static var _cache: Dictionary = {}


## Returns the shared material for [param kind]. Unknown kinds return a
## visible magenta material so mistakes are obvious.
static func get_material(kind: StringName) -> StandardMaterial3D:
	if not _cache.has(kind):
		_cache[kind] = _create(kind)
	return _cache[kind]


static func _create(kind: StringName) -> StandardMaterial3D:
	match kind:
		&"wallpaper":
			return _textured(_wallpaper_texture(), 1.0 / WALL_TILE_METRES, true)
		&"floorboards":
			return _textured(_floorboards_texture(), 0.5, true)
		&"plaster":
			return _textured(_plaster_texture(), 1.0 / 3.0, true)
		&"carpet":
			return _textured(_woven_texture(Color(0.33, 0.13, 0.10), Color(0.22, 0.10, 0.08), 31), 2.0, false)
		&"fabric_olive":
			return _textured(_woven_texture(Color(0.30, 0.31, 0.19), Color(0.24, 0.25, 0.15), 32), 3.0, false)
		&"fabric_curtain":
			return _textured(_woven_texture(Color(0.55, 0.47, 0.28), Color(0.44, 0.36, 0.20), 33), 3.0, false)
		&"wood_dark":
			return _textured(_wood_texture(Color(0.23, 0.14, 0.09), 41), 1.5, false)
		&"wood_stairs":
			return _textured(_wood_texture(Color(0.30, 0.20, 0.13), 42), 1.0, true)
		&"door_panel":
			return _textured(_wood_texture(Color(0.27, 0.16, 0.10), 43), 1.0, true)
		&"plastic_dark":
			return _flat(Color(0.10, 0.095, 0.09), 0.6)
		&"metal_dull":
			return _flat(Color(0.42, 0.41, 0.38), 0.5)
		&"radiator":
			return _flat(Color(0.62, 0.58, 0.47), 0.7)
		&"cardboard":
			return _flat(Color(0.52, 0.40, 0.25), 1.0)
		&"paper":
			return _flat(Color(0.68, 0.64, 0.52), 1.0)
		&"canvas_dark":
			return _flat(Color(0.16, 0.15, 0.12), 1.0)
		&"tv_screen":
			return _emissive(Color(0.50, 0.60, 0.72), 1.4)
		&"bulb":
			return _emissive(Color(1.0, 0.80, 0.48), 3.0)
		&"window_glow":
			return _emissive(Color(0.50, 0.57, 0.60), 0.55)
	push_warning("HouseMaterials: unknown material kind '%s'" % kind)
	return _flat(Color.MAGENTA, 1.0)


## A flat-coloured material for small props (books, cans). Cached by colour.
static func get_flat(color: Color) -> StandardMaterial3D:
	var key: String = "flat_" + color.to_html()
	if not _cache.has(key):
		_cache[key] = _flat(color, 1.0)
	return _cache[key]


static func _flat(color: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	return material


static func _emissive(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color.darkened(0.6)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


static func _textured(texture: Texture2D, tiles_per_metre: float, world_space: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.roughness = 1.0
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
	material.uv1_triplanar = true
	material.uv1_world_triplanar = world_space
	material.uv1_scale = Vector3.ONE * tiles_per_metre
	return material


# --- Texture generation -----------------------------------------------------

## Seamlessly tiling greyscale noise; read values with get_pixel(x, y).r.
static func _noise_image(size: int, noise_seed: int, frequency: float) -> Image:
	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = frequency
	noise.fractal_octaves = 3
	return noise.get_seamless_image(size, size)


static func _finish(image: Image) -> ImageTexture:
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)


static func _hash(value: int) -> float:
	var x: float = sin(float(value) * 12.9898) * 43758.5453
	return x - floorf(x)


## Stained striped wallpaper. One tile is exactly one storey high: row 0 is at
## the ceiling, the last rows are a dark skirting board at the floor.
static func _wallpaper_texture() -> ImageTexture:
	var size: int = 256
	var grime: Image = _noise_image(size, 11, 0.012)
	var fine: Image = _noise_image(size, 12, 0.09)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	var paper := Color(0.60, 0.52, 0.33)
	var motif := Color(0.50, 0.39, 0.23)
	var stain := Color(0.33, 0.25, 0.13)
	var skirting := Color(0.16, 0.10, 0.07)
	# The slab hides the first ~7% of the tile (0.2 m of 2.8 m).
	var ceiling_line: float = HouseLayout.SLAB_THICKNESS / WALL_TILE_METRES
	for y: int in size:
		var t: float = float(y) / float(size - 1)
		for x: int in size:
			var color: Color = paper
			if x % 32 < 3:
				color = color.darkened(0.12)
			if absi((x % 32) - 17) + absi((y % 32) - 16) < 5:
				color = color.lerp(motif, 0.55)
			var grime_value: float = grime.get_pixel(x, y).r
			color = color.darkened(clampf((grime_value - 0.50) * 0.75, 0.0, 0.32))
			color = color.darkened(fine.get_pixel(x, y).r * 0.10)
			# Water stains running down from the ceiling in some columns.
			var reach: float = (grime.get_pixel(x, 3).r - 0.48) * 2.2
			var below_ceiling: float = t - ceiling_line
			if reach > 0.0 and below_ceiling > 0.0 and below_ceiling < reach:
				color = color.lerp(stain, 0.45 * (1.0 - below_ceiling / reach))
			# Dirt rising from the floor.
			if t > 0.72:
				color = color.darkened((t - 0.72) * 1.1)
			if t > 0.955:
				color = skirting.lightened(fine.get_pixel(x, y).r * 0.12)
			image.set_pixel(x, y, color)
	return _finish(image)


## Worn floorboards: 16-pixel planks with staggered end joints.
static func _floorboards_texture() -> ImageTexture:
	var size: int = 128
	var grain: Image = _noise_image(size, 21, 0.06)
	var wear: Image = _noise_image(size, 22, 0.015)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	var base := Color(0.30, 0.21, 0.13)
	var gap := Color(0.07, 0.05, 0.03)
	for y: int in size:
		for x: int in size:
			var plank: int = x / 16
			var color: Color = base.darkened(_hash(plank) * 0.28)
			# Grain is stretched along the plank by sampling noise with a squashed y.
			color = color.darkened(grain.get_pixel(x, (y / 6) % size).r * 0.22)
			color = color.darkened(clampf((wear.get_pixel(x, y).r - 0.5) * 0.9, 0.0, 0.35))
			var joint_offset: int = int(_hash(plank + 100) * 64.0)
			if x % 16 == 0 or (y + joint_offset) % 64 == 0:
				color = gap
			image.set_pixel(x, y, color)
	return _finish(image)


## Yellowed ceiling plaster with damp blotches.
static func _plaster_texture() -> ImageTexture:
	var size: int = 128
	var blotch: Image = _noise_image(size, 51, 0.018)
	var fine: Image = _noise_image(size, 52, 0.12)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	var base := Color(0.52, 0.48, 0.36)
	var damp := Color(0.30, 0.24, 0.13)
	for y: int in size:
		for x: int in size:
			var color: Color = base.darkened(fine.get_pixel(x, y).r * 0.10)
			var amount: float = clampf((blotch.get_pixel(x, y).r - 0.55) * 3.0, 0.0, 0.7)
			color = color.lerp(damp, amount)
			image.set_pixel(x, y, color)
	return _finish(image)


## Coarse two-tone weave for carpet, upholstery and curtains.
static func _woven_texture(light: Color, dark: Color, noise_seed: int) -> ImageTexture:
	var size: int = 64
	var wear: Image = _noise_image(size, noise_seed, 0.04)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var color: Color = light if ((x / 2) + (y / 2)) % 2 == 0 else dark
			color = color.darkened(clampf((wear.get_pixel(x, y).r - 0.45) * 0.45, 0.0, 0.2))
			image.set_pixel(x, y, color)
	return _finish(image)


## Dark varnished wood with long grain streaks.
static func _wood_texture(base: Color, noise_seed: int) -> ImageTexture:
	var size: int = 64
	var grain: Image = _noise_image(size, noise_seed, 0.10)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var streak: float = grain.get_pixel(x, (y / 8) % size).r
			image.set_pixel(x, y, base.darkened(streak * 0.35).lightened(_hash(x) * 0.04))
	return _finish(image)
