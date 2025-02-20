# This is the Procedure resource which represents a recording of steps made 
# by the Creator.

class_name FB_Procedure extends Resource

var steps: Array[Resource]

# Constructor to allow for creating a Procedure from an existing array of steps
func _init(p_steps: Array[Resource] = []) -> void:
	steps = p_steps

# Adds a single step to the _steps
func AddStep(step: Resource) -> void:
	steps.append(step)

# Adds the array of steps to the _steps
func AddSteps(steps: Array[Resource]) -> void:
	steps.append_array(steps)

# Removed the specified step from the _steps
func RemoveStep(step: Resource) -> void:
	steps.erase(step)
