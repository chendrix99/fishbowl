# Resource for each step in a recorded procedure.
#
# A step is emitted by a zone upon entering or exiting the zone area or an 
# object when interacted. That step is then managed by a Procedure resource.

class_name FB_Step extends Resource

var object_id: int
var zone_id: int
var step_type: FB_Globals.StepType

# If the creator chooses to track the object positions, set this when done recording
var object_position: Vector3

func _init(p_object_id: int, p_zone_id: int, p_step_type: FB_Globals.StepType) -> void:
	object_id = p_object_id
	zone_id = p_zone_id
	step_type = p_step_type
