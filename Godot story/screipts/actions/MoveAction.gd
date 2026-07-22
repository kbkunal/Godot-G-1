extends StoryAction
class_name MoveAction

@export var actor_id: String
@export var target: NodePath
@export var speed: float = 2.5
@export var arrive_distance: float = 0.3   # slightly safer

func execute(context):
	var actor = context.registry.get_actor(actor_id)
	if actor == null:
		push_error("MoveAction: Actor not found: " + actor_id)
		return

	if not actor is CharacterBody3D:
		push_error("MoveAction: Actor is not CharacterBody3D")
		return

	# IMPORTANT: get target from current scene, not owner
	var target_node = context.tree.current_scene.get_node_or_null(target)

	if target_node == null:
		push_error("MoveAction: Target not found")
		return

	# 🔒 SAFETY TIMER (prevents infinite lock)
	var elapsed := 0.0
	var max_time := 5.0   # seconds

	while actor.global_position.distance_to(target_node.global_position) > arrive_distance:
		elapsed += context.tree.physics_frame_time
		if elapsed > max_time:
			push_warning("MoveAction: Timeout reached, breaking movement")
			break

		var direction = target_node.global_position - actor.global_position
		direction.y = 0              # ✅ CRITICAL: keep grounded

		if direction.length() > 0.001:
			actor.velocity = direction.normalized() * speed
		else:
			break

		actor.move_and_slide()
		await context.tree.physics_frame

	actor.velocity = Vector3.ZERO
