extends Resource
class_name StoryCondition

# Override this in child conditions
func check(_context: StoryContext) -> bool:
	return false
