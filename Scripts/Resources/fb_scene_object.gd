# This resource stores the data needed for an instance of a scene object.
# object_file_path - The path for the scene file of the object.
# object_transform - The transform to apply to the object.
# object_id - The unique ID of the object in the scene.

class_name FB_SceneObject extends Resource

var object_file_path: String
var object_transform: Transform3D
var object_id: int

# Constructor tp create the resource with specified parameters
func _init(p_object_file_path = "", p_object_transform = Transform3D(), p_object_id = -1) -> void:
	object_file_path = p_object_file_path
	object_transform = p_object_transform
	object_id = p_object_id
