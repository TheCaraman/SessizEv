class_name PeepholeInteraction
extends StaticBody3D
## Small physical target above the handle. E on the door itself still answers it.

var view: PeepholeView


func _ready() -> void:
	name = "Peephole"
	position = Vector3(0.0, 1.48, -0.075)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(0.28, 0.12, 0.035)
	collision.shape = shape
	add_child(collision)
	var ring := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.03
	mesh.bottom_radius = 0.03
	mesh.height = 0.012
	mesh.radial_segments = 32
	mesh.material = HouseMaterials.get_material(&"brass")
	ring.mesh = mesh
	ring.rotation.x = PI * 0.5
	add_child(ring)
	var glass := MeshInstance3D.new()
	var circle := CylinderMesh.new()
	circle.top_radius = 0.019
	circle.bottom_radius = 0.019
	circle.height = 0.015
	circle.radial_segments = 32
	circle.material = HouseMaterials.get_material(&"trim_dark")
	glass.mesh = circle
	glass.rotation.x = PI * 0.5
	glass.position.z = -0.003
	add_child(glass)


func get_interaction_prompt() -> String:
	return tr("PROMPT_PEEPHOLE").format({"key": InputSetup.get_key_label(&"interact")})


func interact(player: Node) -> void:
	if not player is PlayerController or not player.control_enabled:
		return
	if view == null:
		view = PeepholeView.new()
		add_child(view)
	view.open(get_parent() as Node3D, player)
