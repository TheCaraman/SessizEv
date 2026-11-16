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


## The three framed pictures in the corridors. Kept apart from generate_all()
## so regenerating them never touches the surface textures.
## Run through scenes/dev/generate_pictures.tscn.
static func generate_pictures(output_dir: String) -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	_save(painting_landscape(), output_dir, "painting_landscape")
	_save(painting_still_life(), output_dir, "painting_still_life")
	_save(photo_house(), output_dir, "photo_house")


## Smooth 0..1 step across [param edge] +- [param softness].
static func _soft(value: float, edge: float, softness: float) -> float:
	return smoothstep(edge - softness, edge + softness, value)


## A small country landscape in the house's flat painted manner: overcast
## sky, a far ridge, a field, a dark tree line and one white farmhouse.
static func painting_landscape() -> Image:
	var width: int = 480
	var height: int = 360
	var grain: Image = _noise(512, 301, 0.06)
	var ridge := FastNoiseLite.new()
	ridge.seed = 302
	ridge.frequency = 0.012
	var trees := FastNoiseLite.new()
	trees.seed = 303
	trees.frequency = 0.05
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	for y: int in height:
		var v: float = float(y) / height
		for x: int in width:
			var u: float = float(x) / width
			var color := Color(0.66, 0.68, 0.62).lerp(Color(0.80, 0.74, 0.60), v * 1.6)
			# Far ridge, cool and pale.
			var ridge_line: float = 0.46 + ridge.get_noise_1d(x) * 0.07
			color = color.lerp(Color(0.38, 0.47, 0.46), _soft(v, ridge_line, 0.004))
			# Field, dull ochre, a darker band near the bottom.
			color = color.lerp(Color(0.56, 0.50, 0.30), _soft(v, 0.60, 0.004))
			color = color.lerp(Color(0.40, 0.37, 0.22), _soft(v, 0.86, 0.06) * 0.7)
			# Tree line along the field's edge, broken in two places.
			var crown: float = 0.60 - 0.06 - absf(trees.get_noise_1d(x)) * 0.09
			var gap: bool = (u > 0.30 and u < 0.38) or u > 0.88
			if not gap:
				color = color.lerp(Color(0.13, 0.22, 0.17), _soft(v, crown, 0.004) * (1.0 - _soft(v, 0.605, 0.004)))
			# Farmhouse: white wall and a dark roof.
			var house_x: float = absf(u - 0.34)
			if house_x < 0.045 and v > 0.535 and v < 0.60:
				color = Color(0.82, 0.80, 0.70)
			var roof: float = 0.535 - (0.045 - house_x) * 0.75
			if house_x < 0.052 and v > roof and v <= 0.535:
				color = Color(0.25, 0.17, 0.13)
			if absf(u - 0.33) < 0.008 and v > 0.565 and v < 0.60:
				color = Color(0.18, 0.15, 0.12)
			# Brush grain over everything.
			color = color.darkened((grain.get_pixel(x % 512, y % 512).r - 0.5) * 0.10)
			image.set_pixel(x, y, color)
	return image


## A dark still life: a teal jug with dull yellow and red flowers on a
## wooden table, lit from the left.
static func painting_still_life() -> Image:
	var width: int = 320
	var height: int = 420
	var grain: Image = _noise(512, 311, 0.07)
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	# x, y, radius; the colour alternates yellow / red / pale through the list.
	var flowers: Array[Vector3] = [
		Vector3(0.40, 0.27, 0.06), Vector3(0.57, 0.22, 0.055), Vector3(0.68, 0.33, 0.05),
		Vector3(0.31, 0.38, 0.05), Vector3(0.50, 0.35, 0.06), Vector3(0.62, 0.42, 0.04),
		Vector3(0.45, 0.18, 0.04),
	]
	var petals: Array[Color] = [
		Color(0.74, 0.62, 0.26), Color(0.62, 0.20, 0.14), Color(0.78, 0.74, 0.62),
	]
	for y: int in height:
		var v: float = float(y) / height
		for x: int in width:
			var u: float = float(x) / width
			var light: float = clampf(1.15 - u * 0.9, 0.35, 1.0)
			var color := Color(0.17, 0.18, 0.14) * light
			# Table top and front edge.
			color = color.lerp(Color(0.33, 0.21, 0.11) * light, _soft(v, 0.76, 0.004))
			color = color.lerp(Color(0.20, 0.12, 0.06), _soft(v, 0.84, 0.004))
			# Jug: an ellipse with a narrower neck.
			var body_d: float = Vector2((u - 0.5) / 0.17, (v - 0.64) / 0.13).length()
			var neck: bool = absf(u - 0.5) < 0.07 and v > 0.44 and v < 0.56
			if body_d < 1.0 or neck:
				var shade: float = clampf(0.55 + (0.5 - u) * 1.6, 0.25, 1.0)
				color = Color(0.16, 0.38, 0.36) * shade
				if body_d < 0.35 and u < 0.47:
					color = color.lightened(0.25)
			# Stems and a few leaves rising from the neck.
			for i: int in flowers.size():
				var flower: Vector3 = flowers[i]
				if v > flower.y and v < 0.46:
					var t: float = (v - flower.y) / (0.46 - flower.y)
					var stem_x: float = lerpf(flower.x, 0.5 + (flower.x - 0.5) * 0.15, t)
					if absf(u - stem_x) < 0.006:
						color = Color(0.20, 0.30, 0.16) * light
			for leaf: Vector3 in [Vector3(0.39, 0.44, 0.0), Vector3(0.61, 0.45, 0.0)]:
				var leaf_d: float = Vector2((u - leaf.x) / 0.07, (v - leaf.y) / 0.025).length()
				if leaf_d < 1.0:
					color = Color(0.22, 0.34, 0.18) * light
			# Flower heads, each with a darker centre.
			for i: int in flowers.size():
				var flower: Vector3 = flowers[i]
				var d: float = Vector2(u - flower.x, (v - flower.y) * 0.76).length()
				if d < flower.z:
					var petal: Color = petals[i % petals.size()]
					color = petal * clampf(1.1 - d / flower.z * 0.5, 0.5, 1.0) * light
					if d < flower.z * 0.3:
						color = color.darkened(0.45)
			color = color.darkened((grain.get_pixel(x % 512, y % 512).r - 0.5) * 0.12)
			image.set_pixel(x, y, color)
	return image


## A faded sepia photograph of a house porch with a white paper border.
static func photo_house() -> Image:
	var width: int = 400
	var height: int = 300
	var grain: Image = _noise(512, 321, 0.18)
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGB8)
	for y: int in height:
		var v: float = float(y) / height
		for x: int in width:
			var u: float = float(x) / width
			var tone: float = 0.78 - v * 0.25
			# Trees either side, darker toward their middles.
			for tree: Vector3 in [Vector3(0.12, 0.42, 0.13), Vector3(0.90, 0.47, 0.10)]:
				var tree_d: float = Vector2((u - tree.x) / tree.z, (v - tree.y) / (tree.z * 1.9)).length()
				if tree_d < 1.0:
					tone = lerpf(0.30, 0.46, tree_d)
			# House front: clapboard wall, roof, door, two windows.
			if u > 0.24 and u < 0.76 and v > 0.36 and v < 0.82:
				tone = 0.60 - (0.04 if int(v * 60.0) % 2 == 0 else 0.0)
				if absf(u - 0.5) < 0.045 and v > 0.58:
					tone = 0.22
				for wx: float in [0.35, 0.65]:
					if absf(u - wx) < 0.055 and v > 0.46 and v < 0.62:
						tone = 0.28 if absf(u - wx) > 0.006 and absf(v - 0.54) > 0.006 else 0.62
			var roof: float = 0.36 - (0.29 - absf(u - 0.5)) * 0.62
			if absf(u - 0.5) < 0.30 and v > roof and v <= 0.36:
				tone = 0.24 + (0.03 if int(v * 80.0) % 2 == 0 else 0.0)
			# Porch roof and its two posts.
			if u > 0.20 and u < 0.80 and v > 0.545 and v < 0.565:
				tone = 0.32
			for px: float in [0.23, 0.77]:
				if absf(u - px) < 0.008 and v > 0.565 and v < 0.82:
					tone = 0.70
			if v > 0.82:
				tone = 0.46 - (v - 0.82) * 0.8
			# Fading toward the edges, then the white border.
			var edge: float = Vector2(u - 0.5, v - 0.5).length()
			tone = lerpf(tone, 0.80, _soft(edge, 0.52, 0.12) * 0.6)
			tone += (grain.get_pixel(x % 512, y % 512).r - 0.5) * 0.08
			var color := Color(tone * 1.06, tone * 0.94, tone * 0.76)
			if u < 0.06 or u > 0.94 or v < 0.07 or v > 0.93:
				color = Color(0.86, 0.83, 0.74)
			image.set_pixel(x, y, color)
	return image


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
	var base := Color(0.54, 0.48, 0.37)
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
