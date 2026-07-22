extends MultiMeshInstance3D

@export var ground_path: NodePath
@export var grass_count: int = 2000
@export var scatter_radius: float = 40.0
@export var ray_height: float = 50.0

@export var min_height: float = 0.7
@export var max_height: float = 1.6
@export var min_width: float = 0.6
@export var max_width: float = 1.0

func _ready():
	randomize()

	var ground = get_node_or_null(ground_path)
	if ground == null:
		push_error("Grass: Ground node not found!")
		return

	multimesh.instance_count = grass_count

	var space_state = get_world_3d().direct_space_state

	for i in range(grass_count):

		# Random XZ position
		var x = randf_range(-scatter_radius, scatter_radius)
		var z = randf_range(-scatter_radius, scatter_radius)

		var ray_from = Vector3(x, ray_height, z)
		var ray_to = Vector3(x, -ray_height, z)

		var query = PhysicsRayQueryParameters3D.create(
			ray_from,
			ray_to
		)
		query.collide_with_areas = false
		query.collide_with_bodies = true

		var result = space_state.intersect_ray(query)

		if result.is_empty():
			continue

		# Hit position on ground
		var hit_pos: Vector3 = result.position
		var hit_normal: Vector3 = result.normal

		# Align grass slightly to ground normal
		var up = hit_normal
		var rot_basis = Basis().looking_at(up, Vector3.FORWARD)

		# Random Y rotation
		rot_basis = rot_basis.rotated(Vector3.UP, randf() * TAU)

		# Random blade size
		var blade_scale = Vector3(
			randf_range(min_width, max_width),
			randf_range(min_height, max_height),
			randf_range(min_width, max_width)
		)

		var t = Transform3D()
		t.basis = rot_basis.scaled(blade_scale)
		t.origin = hit_pos

		multimesh.set_instance_transform(i, t)
