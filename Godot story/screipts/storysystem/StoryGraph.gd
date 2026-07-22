extends Node
class_name StoryGraph

# Where the story begins
@export var start_node: NodePath

func play(context: StoryContext) -> void:
	var current_node = get_node(start_node)

	while current_node:
		# Run the current story node
		var next_paths: Array[NodePath] = await current_node.play(context)

		# Decide the next node
		current_node = _choose_next_node(next_paths, current_node, context)

func _choose_next_node(
	next_paths: Array[NodePath],
	current_node,
	context: StoryContext
):
	# No next nodes → end story
	if next_paths.is_empty():
		return null

	# If no conditions defined, go to first node
	if current_node.conditions.is_empty():
		return get_node(next_paths[0])

	# Evaluate conditions in order
	for i in range(min(next_paths.size(), current_node.conditions.size())):
		var condition = current_node.conditions[i]
		if condition and condition.check(context):
			return get_node(next_paths[i])

	# No condition matched
	return null
