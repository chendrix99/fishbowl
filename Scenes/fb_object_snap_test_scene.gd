# Copied from fb_proto_scene.gd - consider refactoring to be shared code

@tool
extends XRToolsSceneBase

# This will need to change and perhaps necessitate more variables
# depending on how we structure/store the assets packaged,
# they are just all in Assets right now for ease
const OBJECT_PATH: String = "res://Assets/"

@onready var wrist_menu: Node3D = $FBWristMenu

@onready var pointer: Node3D = $XROrigin3D/RightHand/FunctionPointer
@onready var pointer_raycast: RayCast3D = $XROrigin3D/RightHand/FunctionPointer/RayCast

var selected_wrist_menu_item: Node3D = null

var in_placement_mode: bool = false

#-------------------------------------------------------------------------------
func _ready() -> void:
	super()
	wrist_menu.object_callback = self.proto_scene_object_menu_callback
	wrist_menu.zone_callback = self.proto_scene_zone_menu_callback
	wrist_menu.populate_objects(OBJECT_PATH)
	wrist_menu.populate_zones(OBJECT_PATH)

#-------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if selected_wrist_menu_item != null:
		_update_selected_wrist_menu_item()

#-------------------------------------------------------------------------------
func hide_wrist_menu(name: String) -> bool:
	if name == "ax_button" and not in_placement_mode:
		if wrist_menu.is_shown:
			remove_child(wrist_menu)
			wrist_menu.set_is_shown(false)
		else:
			add_child(wrist_menu)
			wrist_menu.set_is_shown(true)
	return true

#-------------------------------------------------------------------------------
# Currently, the two menu item callback functions here are the same, but the
# behavior may need to diverge at some point in the future.
func proto_scene_object_menu_callback(asset_file: String) -> void:
	# Remove the menu when we are placing
	remove_child(wrist_menu)
	wrist_menu.set_is_shown(false)
	in_placement_mode = true
	
	# Initialize the object for placement
	selected_wrist_menu_item = load(OBJECT_PATH+asset_file).instantiate()
	selected_wrist_menu_item.get_child(0).enabled = false
	add_child(selected_wrist_menu_item)

#-------------------------------------------------------------------------------
func proto_scene_zone_menu_callback(asset_file: String) -> void:
	# Remove the menu when we are placing
	remove_child(wrist_menu)
	wrist_menu.set_is_shown(false)
	in_placement_mode = true
	
	# Initialize the object for placement
	selected_wrist_menu_item = load(OBJECT_PATH+asset_file).instantiate()
	selected_wrist_menu_item.get_child(0).enabled = false
	add_child(selected_wrist_menu_item)

#-------------------------------------------------------------------------------
func handle_object_placement(name: String) -> bool:
	if name == "trigger_click" and in_placement_mode:
		in_placement_mode = false
		
		selected_wrist_menu_item.get_child(0).enabled = true
		selected_wrist_menu_item = null
		
		add_child(wrist_menu)
		wrist_menu.set_is_shown(true)
	return true

#-------------------------------------------------------------------------------
func _update_selected_wrist_menu_item() -> void:
	if pointer_raycast.is_colliding() and in_placement_mode:
		var collision_normal: Vector3 = pointer_raycast.get_collision_normal()
		var xform: Transform3D = Transform3D(self.global_transform)
		selected_wrist_menu_item.global_transform = align_with_normal(xform, collision_normal)
		if pointer.last_collided_at != null:
			selected_wrist_menu_item.global_transform.origin = pointer.last_collided_at + (collision_normal*0.055)

#-------------------------------------------------------------------------------
func align_with_normal(xform: Transform3D, normal: Vector3) -> Transform3D:
	xform.basis.y = normal.normalized()
	xform.basis.x = -xform.basis.z.cross(xform.basis.y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform
