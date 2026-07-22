extends Node
class_name ActorRegistry

var actors: Dictionary = {}

func register_actor(id: String, node: Node) -> void:
	if id.is_empty():
		push_error("Actor ID cannot be empty")
		return
	if node == null:
		push_error("Cannot register null actor")
		return
	actors[id] = node

func get_actor(id: String) -> Node:
	if not actors.has(id):
		push_error("Actor not found: " + id)
		return null
	return actors[id]

func _ready():
	register_actor("player", $"../Player")
	register_actor("guard", $"../NPC_Guard")
	register_actor("dog", $"../NPC_Dog")
