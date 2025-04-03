# Resource for each recorded step in a level.

class_name FB_Step extends Resource


@export var object_ID: int
@export var zone_ID: int
@export var step_type: FB_Globals.StepType
@export var step_description: StringName


func _init(_object_ID: int = -1, _zone_ID: int = -1, _step_type: FB_Globals.StepType = FB_Globals.StepType.INVALID, _step_description: StringName = "") -> void:
	object_ID = _object_ID
	zone_ID = _zone_ID
	step_type = _step_type
	step_description = _step_description


func is_equal_to(other: FB_Step) -> bool:
	return object_ID == other.object_ID and zone_ID == other.zone_ID and step_type == other.step_type
