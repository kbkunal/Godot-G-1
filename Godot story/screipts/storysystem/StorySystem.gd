extends Node
class_name StorySystem

@export var story_graph: NodePath
@export var actor_registry: NodePath

func _ready():
	print("📖 StorySystem started")

	var graph = get_node_or_null(story_graph)
	var registry = get_node_or_null(actor_registry)

	if graph == null:
		push_error("StorySystem: StoryGraph not assigned")
		return

	if registry == null:
		push_error("StorySystem: ActorRegistry not assigned")
		return

	print("▶ Creating StoryContext")

	var context = StoryContext.new(
		registry,
		get_tree(),
		get_tree().current_scene
	)

	print("▶ Starting StoryGraph")
	await graph.play(context)
	print("⏹ StoryGraph finished")
