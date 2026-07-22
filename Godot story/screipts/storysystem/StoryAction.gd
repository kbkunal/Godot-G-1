extends Resource
class_name StoryAction

# This method will be overridden by child actions
# It can be async using 'await'
func execute(_context: StoryContext) -> void:
	pass
