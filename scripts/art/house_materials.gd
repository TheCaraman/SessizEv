class_name HouseMaterials
extends RefCounted
## Shared materials for the 3D corridors, with textures generated in code.
##
## Palette (docs/DecisionLog.md, K-012): dark dirty green and teal, with dirty
## yellow as the accent. Textures are low-resolution but shown crisp.
## Any of them can later be replaced by a painted texture without touching
## the code that uses the material.
##
## Wall and floor materials use world-space triplanar mapping so box geometry
## needs no UV work.

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
		&"wallpaper_green":
			return _triplanar(_wallpaper_texture(), 1.0 / WALL_TILE_METRES)
		&"parquet":
			return _triplanar(_parquet_texture(), 1.0)
		&"wood_stairs":
			return _triplanar(_wood_texture(Color(0.20, 0.15, 0.09), 42), 1.0)
		&"door_paint":
			return _triplanar(_painted_wood_texture(Color(0.44, 0.39, 0.20), 61), 1.0)
		&"door_panel_paint":
			return _triplanar(_painted_wood_texture(Color(0.50, 0.45, 0.24), 62), 1.0)
		&"frame_paint":
			return _triplanar(_painted_wood_texture(Color(0.66, 0.66, 0.56), 63), 1.0)
		&"runner":
			return _uv_mapped(_runner_texture())
		&"ceiling_dark":
			return _flat(Color(0.035, 0.07, 0.06), 1.0)
		&"brass":
			return _flat(Color(0.42, 0.35, 0.16), 0.45)
		&"lamp_shade":
			return _emissive(Color(1.0, 0.90, 0.66), 2.2)
	push_warning("HouseMaterials: unknown material kind '%s'" % kind)
	return _flat(Color.MAGENTA, 1.0)


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


static func _triplanar(texture: Texture2D, tiles_per_metre: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = _uv_mapped(texture)
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE * tiles_per_metre
	return material


static func _uv_mapped(texture: Texture2D) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	material.roughness = 1.0
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
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


## Dark green wallpaper with a dirty-yellow leaf motif. One tile is exactly
## one storey high: row 0 is at the ceiling, the last rows are the skirting.
static func _wallpaper_texture() -> ImageTexture:
	var size: int = 256
	var grime: Image = _noise_image(size, 11, 0.012)
	var fine: Image = _noise_image(size, 12, 0.09)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	var paper := Color(0.11, 0.25, 0.21)
	var paper_light := Color(0.15, 0.31, 0.25)
	var motif := Color(0.58, 0.49, 0.18)
	var motif_dark := Color(0.36, 0.33, 0.13)
	var skirting := Color(0.50, 0.48, 0.38)
	var ceiling_line: float = HouseLayout.SLAB_THICKNESS / WALL_TILE_METRES
	for y: int in size:
		var t: float = float(y) / float(size - 1)
		for x: int in size:
			# Mottled ground between two greens.
			var color: Color = paper.lerp(paper_light, fine.get_pixel(x, y).r)

			# Motif on a 32-pixel grid, every other row shifted by half a cell.
			var row: int = y / 32
			var cell_x: int = (x + (16 if row % 2 == 1 else 0)) % 32
			var dx: int = cell_x - 16
			var dy: int = (y % 32) - 16
			var ax: int = absi(dx)
			var ay: int = absi(dy)
			if ax + ay <= 2:
				color = motif
			elif (ax <= 1 and ay <= 7) or (ay <= 1 and ax <= 7):
				color = motif if (ax + ay) % 3 != 0 else motif_dark
			elif absi(ax - ay) <= 1 and ax >= 3 and ax <= 6:
				color = motif_dark
			elif ax >= 13 and ay >= 13 and (ax + ay) % 2 == 0:
				color = motif_dark

			# Grime, damp from above, dirt from below.
			var grime_value: float = grime.get_pixel(x, y).r
			color = color.darkened(clampf((grime_value - 0.50) * 0.8, 0.0, 0.35))
			var reach: float = (grime.get_pixel(x, 3).r - 0.50) * 2.0
			var below_ceiling: float = t - ceiling_line
			if reach > 0.0 and below_ceiling > 0.0 and below_ceiling < reach:
				color = color.darkened(0.45 * (1.0 - below_ceiling / reach))
			if t > 0.80:
				color = color.darkened((t - 0.80) * 1.2)

			if t > 0.955:
				color = skirting.darkened(fine.get_pixel(x, y).r * 0.25)
			elif t > 0.948:
				color = Color(0.04, 0.07, 0.06)
			image.set_pixel(x, y, color)
	return _finish(image)


## Dark herringbone-style parquet: short blocks alternating direction.
static func _parquet_texture() -> ImageTexture:
	var size: int = 128
	var grain: Image = _noise_image(size, 21, 0.08)
	var wear: Image = _noise_image(size, 22, 0.015)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	var base := Color(0.20, 0.17, 0.10)
	var gap := Color(0.04, 0.05, 0.03)
	for y: int in size:
		for x: int in size:
			# 32-pixel squares, each made of four 8-pixel strips, alternating direction.
			var block_x: int = x / 32
			var block_y: int = y / 32
			var horizontal: bool = (block_x + block_y) % 2 == 0
			var along: int = (x % 32) if horizontal else (y % 32)
			var across: int = (y % 32) if horizontal else (x % 32)
			var strip: int = across / 8
			var color: Color = base.darkened(_hash(block_x * 7 + block_y * 13 + strip * 31) * 0.30)
			color = color.darkened(grain.get_pixel(x, y).r * 0.15)
			color = color.darkened(clampf((wear.get_pixel(x, y).r - 0.5) * 0.9, 0.0, 0.3))
			if across % 8 == 0 or along == 0:
				color = gap
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


## Old gloss paint over wood: vertical brush streaks, chips and grubby patches.
static func _painted_wood_texture(base: Color, noise_seed: int) -> ImageTexture:
	var size: int = 64
	var streaks: Image = _noise_image(size, noise_seed, 0.20)
	var dirt: Image = _noise_image(size, noise_seed + 100, 0.03)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var streak: float = streaks.get_pixel(x, (y / 10) % size).r
			var color: Color = base.darkened(streak * 0.22)
			color = color.darkened(clampf((dirt.get_pixel(x, y).r - 0.45) * 0.9, 0.0, 0.35))
			if streaks.get_pixel(x, y).r > 0.90:
				color = Color(0.20, 0.15, 0.08)
			image.set_pixel(x, y, color)
	return _finish(image)


## Carpet runner. U runs across the runner, V along it; the tile repeats along
## the length. Dark green border, dirty ochre field, a diamond in each tile.
static func _runner_texture() -> ImageTexture:
	var size: int = 64
	var wear: Image = _noise_image(size, 71, 0.05)
	var image := Image.create_empty(size, size, true, Image.FORMAT_RGB8)
	var border := Color(0.07, 0.17, 0.14)
	var line := Color(0.60, 0.50, 0.20)
	var field := Color(0.40, 0.31, 0.12)
	var figure := Color(0.10, 0.22, 0.18)
	for y: int in size:
		for x: int in size:
			var edge: int = mini(x, size - 1 - x)
			var color: Color = field
			if edge < 5:
				color = border if (y / 4) % 2 == 0 or edge < 2 else line
			elif edge < 7:
				color = line
			elif edge < 9:
				color = border
			else:
				var dx: int = absi(x - 32)
				var dy: int = absi(y - 32)
				if dx + dy < 6:
					color = line
				elif dx + dy < 16:
					color = figure
				elif dx + dy < 18:
					color = line
				elif (x + y) % 8 == 0 or (x - y + 64) % 8 == 0:
					color = field.darkened(0.25)
			color = color.darkened(clampf((wear.get_pixel(x, y).r - 0.4) * 0.6, 0.0, 0.3))
			image.set_pixel(x, y, color)
	return _finish(image)
