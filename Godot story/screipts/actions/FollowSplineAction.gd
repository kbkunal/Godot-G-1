extends StoryAction
class_name FollowSplineAction

@export var actor_id: String
@export var path: NodePath
@export var speed: float = 2.5
@export var arrive_distance: float = 0.2

func execute(context):
	print("FOLLOW SPLINE ACTION STARTED:", actor_id)

	var actor = context.registry.get_actor(actor_id)
	if actor == null:
		push_error("Actor not found: " + actor_id)
		return

	if not actor is CharacterBody3D:
		push_error("Actor is not CharacterBody3D")
		return

	var path_node: Path3D = context.tree.current_scene.get_node_or_null(path)
	if path_node == null:
		push_error("Invalid Path3D")
		return

	var curve: Curve3D = path_node.curve
	if curve == null or curve.point_count < 2:
		push_error("Curve has insufficient points")
		return

	# 🔥 FORCE BAKE (CRITICAL)
	curve.bake_interval = 0.2
	curve.get_baked_points()

	var distance: float = 0.0
	var total_length: float = curve.get_baked_length()

	print("Spline length:", total_length)

	if total_length <= 0.0:
		push_error("Spline length is ZERO")
		return

	while distance < total_length:
		var local_pos: Vector3 = curve.sample_baked(distance)
		var target_pos: Vector3 = path_node.to_global(local_pos)

		var dir: Vector3 = target_pos - actor.global_position
		dir.y = 0

		print("DIST:", distance, "DIR:", dir.length())

		if dir.length() > arrive_distance:
			actor.velocity = dir.normalized() * speed
		else:
			distance += 0.5

		actor.move_and_slide()
		await context.tree.physics_frame

	actor.velocity = Vector3.ZERO
	print("FOLLOW SPLINE FINISHED:", actor_id)
