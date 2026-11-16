class_name TextureGenerator
extends RefCounted
## Generates the corridor textures as PNG files (developer tool).
##
## Shapes are computed in resolution-independent units and anti-aliased, so
## the results are smooth rather than blocky. The files are ordinary assets:
## replace any of them with a painted texture of the same name and the game
## uses it. Run through scenes/main/generate_textures.tscn.
##
## Palette (docs/DecisionLog.md, K-012): dark dirty green and teal with dirty
## yellow accents.

const WALLPAPER_SIZE: int = 1024
const DETAIL_SIZE: int = 512


static func generate_all(output_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	_save(_wallpaper(), output_dir, "wallpaper")
	_save(corridor_floorboards(), output_dir, "parquet")
	_save(_painted_wood(Color(0.08, 0.21, 0.20), 61), output_dir, "door_paint")
	_save(_painted_wood(Color(0.11, 0.26, 0.24), 62), output_dir, "door_panel_paint")
	_save(_painted_wood(Color(0.50, 0.50, 0.42), 63), output_dir, "frame_paint")
	_save(_painted_wood(Color(0.06, 0.13, 0.11), 64), output_dir, "trim_dark")
	_save(_varnished_wood(Color(0.22, 0.16, 0.09), 42), output_dir, "wood_stairs")
	_save(_runner(), output_dir, "runner")


static func _save(image: Image, output_dir: String, file_name: String) -> void:
	var path: String = "%s/%s.png" % [output_dir, file_name]
	var error: Error = image.save_png(ProjectSettings.globalize_path(path))
	print("%s -> %s" % [path, error_string(error)])

static func corridor_floorboards() -> Image:
	var size: int = DETAIL_SIZE
	var grain: Image = _noise(size, 84, 0.012)
	var image := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var board: int = int(float(x) / size * 6.0)
			var across: float = fmod(float(x) / size * 6.0, 1.0)
			var color := Color(0.24, 0.18, 0.12).darkened(_hash(board, 0, 9) * 0.18 + floorf(grain.get_pixel(x, y).r * 5.0) * 0.012)
			if across < 0.018 or across > 0.985 or y == 0:
				color = Color(0.035, 0.045, 0.03)
			image.set_pixel(x, y, color)
	return image


## Seamlessly tiling greyscale noise; read values with get_pixel(x, y).r.
static func _noise(size: int, noise_seed: int, frequency: float) -> Image:
	var noise := FastNoiseLite.new()
	noise.seed = noise_seed
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX_SMOOTH
	noise.frequency = frequency
	noise.fractal_octaves = 4
	return noise.get_seamless_image(size, size)


static func _hash(a: int, b: int, c: int) -> float:
	var x: float = sin(float(a) * 127.1 + float(b) * 311.7 + float(c) * 74.7) * 43758.5453
	return x - floorf(x)


## Quiet matte plaster: broad irregular painted patches, no decorative repeat.
static func _wallpaper() -> Image:
	var size: int = WALLPAPER_SIZE
	var mottle: Image = _noise(size, 11, 0.008)
	var damp: Image = _noise(size, 12, 0.003)
	var base := Color(0.43, 0.32, 0.27)
	var image := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var patch: float = floorf(mottle.get_pixel(x, y).r * 6.0) / 6.0
			var color: Color = base.darkened(patch * 0.17)
			color = color.lerp(Color(0.23, 0.29, 0.24), clampf((damp.get_pixel(x, y).r - 0.47) * 0.7, 0.0, 0.20))
			image.set_pixel(x, y, color)
	return image

## Dark block parquet. One tile covers 1 m: four squares across, each made of
## four strips, alternating direction.
static func _parquet() -> Image:
	var size: int = DETAIL_SIZE
	var grain: Image = _noise(size, 21, 0.05)
	var wear: Image = _noise(size, 22, 0.006)
	var base := Color(0.26, 0.18, 0.10)
	var gap := Color(0.02, 0.03, 0.02)
	var unit: float = 128.0 / float(size)
	var image := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	for y: int in size:
		var ly: float = float(y) * unit
		for x: int in size:
			var lx: float = float(x) * unit
			var block_x: int = int(lx / 32.0)
			var block_y: int = int(ly / 32.0)
			var horizontal: bool = (block_x + block_y) % 2 == 0
			var along: float = fmod(lx, 32.0) if horizontal else fmod(ly, 32.0)
			var across: float = fmod(ly, 32.0) if horizontal else fmod(lx, 32.0)
			var strip: int = int(across / 8.0)
			var color: Color = base.lightened(_hash(block_x, block_y, strip) * 0.16)
			# Grain runs along the strip: squash the sampling coordinate across it.
			var grain_x: int = x if horizontal else int(float(x) * 0.18) % size
			var grain_y: int = int(float(y) * 0.18) % size if horizontal else y
			color = color.darkened(grain.get_pixel(grain_x, grain_y).r * 0.30)
			color = color.darkened(clampf((wear.get_pixel(x, y).r - 0.5) * 1.2, 0.0, 0.35))
			# Soft dark joints between strips and at block edges.
			var joint: float = minf(fmod(across, 8.0), along)
			color = color.lerp(gap, clampf(1.0 - joint / 0.45, 0.0, 1.0))
			image.set_pixel(x, y, color)
	return image


## Old gloss paint over wood: faint vertical brush streaks and grubby patches.
static func _painted_wood(base: Color, noise_seed: int) -> Image:
	var size: int = DETAIL_SIZE
	var streaks: Image = _noise(size, noise_seed, 0.06)
	var dirt: Image = _noise(size, noise_seed + 100, 0.006)
	var image := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var streak: float = streaks.get_pixel(x, int(float(y) * 0.06) % size).r
			var color: Color = base.darkened(streak * 0.16)
			color = color.darkened(clampf((dirt.get_pixel(x, y).r - 0.42) * 1.0, 0.0, 0.40))
			image.set_pixel(x, y, color)
	return image


## Dark varnished wood with long grain.
static func _varnished_wood(base: Color, noise_seed: int) -> Image:
	var size: int = DETAIL_SIZE
	var grain: Image = _noise(size, noise_seed, 0.05)
	var image := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	for y: int in size:
		for x: int in size:
			var streak: float = grain.get_pixel(x, int(float(y) * 0.08) % size).r
			image.set_pixel(x, y, base.darkened(streak * 0.40))
	return image


## Carpet runner. U runs across the runner, V along it; the tile repeats along
## the length. Dark green border, ochre field, a diamond medallion per tile.
static func _runner() -> Image:
	var size: int = DETAIL_SIZE
	var pile: Image = _noise(size, 71, 0.25)
	var wear: Image = _noise(size, 72, 0.008)
	var border := Color(0.15, 0.04, 0.04)
	var line := Color(0.62, 0.55, 0.38)
	var field := Color(0.36, 0.09, 0.08)
	var figure := Color(0.10, 0.17, 0.20)
	var unit: float = 64.0 / float(size)
	var image := Image.create_empty(size, size, false, Image.FORMAT_RGB8)
	for y: int in size:
		var ly: float = float(y) * unit
		for x: int in size:
			var lx: float = float(x) * unit
			var edge: float = minf(lx, 64.0 - lx)
			var color: Color = field
			if edge < 2.0:
				color = border
			elif edge < 5.0:
				# A row of small diamonds in the border band.
				var t: float = absf(fmod(ly, 4.0) - 2.0) + absf(edge - 3.5)
				color = line if t < 1.3 else border
			elif edge < 6.0:
				color = line
			elif edge < 8.0:
				color = border
			elif edge < 8.6:
				color = line
			else:
				var d: float = absf(lx - 32.0) + absf(ly - 32.0)
				if d < 4.0:
					color = line
				elif d < 13.0:
					color = figure
				elif d < 14.2:
					color = line
				elif d < 17.0:
					color = field.darkened(0.3)
				else:
					# Faint lattice in the field.
					var a: float = absf(fmod(lx + ly, 8.0) - 4.0)
					var b: float = absf(fmod(lx - ly + 64.0, 8.0) - 4.0)
					if minf(a, b) < 0.35:
						color = field.darkened(0.28)
			color = color.darkened(pile.get_pixel(x, y).r * 0.18)
			color = color.darkened(clampf((wear.get_pixel(x, y).r - 0.45) * 1.0, 0.0, 0.35))
			image.set_pixel(x, y, color)
	return image
