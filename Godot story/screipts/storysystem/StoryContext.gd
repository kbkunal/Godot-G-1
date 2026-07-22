class_name StoryContext

# Global references
var registry: ActorRegistry
var tree: SceneTree
var owner: Node

# Story state
var flags: Dictionary = {}

func _init(_registry: ActorRegistry, _tree: SceneTree, _owner: Node) -> void:
	registry = _registry
	tree = _tree
	owner = _owner
