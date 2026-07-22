extends Node
class_name StoryNode

# Actions to run when this node plays
@export var actions: Array[StoryAction] = []

# Possible next story nodes (paths in scene tree)
@export var next_nodes: Array[NodePath] = []

# Optional conditions for branching (checked later by StoryGraph)
@export var conditions: Array = []

func play(context: StoryContext) -> Array[NodePath]:
	# Run all actions in order
	for action in actions:
		if action:
			await action.execute(context)

	# Return possible next paths
	return next_nodes
