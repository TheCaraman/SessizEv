class_name HouseMaterials
extends RefCounted
## Shared materials for the 3D corridors.
##
## Textures are PNG files in assets/textures/ (written by TextureGenerator, or
## painted by hand under the same names). They are shown smooth: linear
## filtering with mipmaps and anisotropy, never blocky nearest-neighbour
## sampling (docs/DecisionLog.md, K-012 and K-013).
##
## Wall and floor materials use world-space triplanar mapping so box geometry
## needs no UV work.

const TEXTURE_PATH: String = "res://assets/textures/%s.png"

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
			return _triplanar(kind, 0.5)
		&"wainscot":
			return _flat(Color(0.085, 0.15, 0.125), 1.0)
		&"door_paint":
			return _triplanar(kind, 0.7)
		&"door_panel_paint":
			return _triplanar(kind, 0.7)
		&"frame_paint":
			return _flat(Color(0.16, 0.21, 0.18), 1.0)
		&"trim_dark":
			return _flat(Color(0.035, 0.065, 0.05), 1.0)
		&"parquet", &"wood_stairs":
			return _triplanar(kind, 1.0)
		&"trim_door":
			# The shadowed moulding around each door panel: the door paint, darker.
			return _flat(Color(0.04, 0.085, 0.065), 1.0)
		&"runner":
			return _uv_mapped(kind)
		&"ceiling":
			return _flat(Color(0.62, 0.60, 0.51), 1.0)
		&"curtain":
			return _flat(Color(0.47, 0.42, 0.33), 1.0)
		&"window_sky":
			return _emissive(Color(0.74, 0.80, 0.84), 0.9)
		&"brass":
			var brass: StandardMaterial3D = _flat(Color(0.45, 0.36, 0.15), 0.35)
			brass.metallic = 0.7
			return brass
		&"lamp_shade":
			return _emissive(Color(1.0, 0.90, 0.66), 2.2)
	push_warning("HouseMaterials: unknown material kind '%s'" % kind)
	return _flat(Color.MAGENTA, 1.0)


## A plain-coloured material for small props (coats, books, shoes). Cached by colour.
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


static func _triplanar(texture_name: StringName, tiles_per_metre: float) -> StandardMaterial3D:
	var material: StandardMaterial3D = _uv_mapped(texture_name)
	material.uv1_triplanar = true
	material.uv1_world_triplanar = true
	material.uv1_scale = Vector3.ONE * tiles_per_metre
	return material


static func _uv_mapped(texture_name: StringName) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.roughness = 0.9
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	var texture: Texture2D = _load_texture(texture_name)
	if texture == null:
		material.albedo_color = Color.MAGENTA
	else:
		material.albedo_texture = texture
	return material


## Loads a texture file and gives it mipmaps so it stays clean at a distance.
static func _load_texture(texture_name: StringName) -> Texture2D:
	var path: String = TEXTURE_PATH % texture_name
	if not ResourceLoader.exists(path):
		push_warning("HouseMaterials: missing texture %s (run generate_textures.tscn)" % path)
		return null
	var source := load(path) as Texture2D
	var image: Image = source.get_image()
	if image.is_compressed():
		image.decompress()
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
