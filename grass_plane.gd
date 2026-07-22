@tool
extends MeshInstance3D

@export var grass_mesh: Mesh
@export var grass_material: Material
@export var grass_count := 200
@export var min_scale := 0.7
@export var max_scale := 1.4
@export var height_offset := 0.05

var _dirty := true

func _enter_tree():
	if Engine.is_editor_hint():
		_dirty = true
		generate_grass()

func _process(delta):
	if Engine.is_editor_hint() and _dirty:
		_dirty = false
		generate_grass()

func _exit_tree():
	clear_grass()

func generate_grass():
	clear_grass()

	if grass_mesh == null:
		return

	if mesh == null or !(mesh is PlaneMesh):
		return

	var plane := mesh as PlaneMesh
	var half_x := plane.size.x * 0.5
	var half_z := plane.size.y * 0.5

	randomize()

	for i in range(grass_count):
		var blade := MeshInstance3D.new()
		blade.mesh = grass_mesh

		if grass_material:
			blade.material_override = grass_material

		var x := randf_range(-half_x, half_x)
		var z := randf_range(-half_z, half_z)
		blade.position = Vector3(x, height_offset, z)

		blade.rotation.y = randf() * TAU

		var s := randf_range(min_scale, max_scale)
		blade.scale = Vector3(s, s, s)

		# REQUIRED for editor visibility
		blade.owner = get_owner()

		add_child(blade)

func clear_grass():
	for c in get_children():
		c.free()

# Call this when values change
func _set(property, value):
	_dirty = true
	return false
