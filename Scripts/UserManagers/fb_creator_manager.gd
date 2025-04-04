class_name FB_CreatorManager extends Node3D

# The FB Creator Manager class contains the logic needed to edit a scene as a Creator.
# This currently includes utilities to place/remove objects and place/extrude/remove zones.

@onready var _user := get_parent().get_node("XROrigin3D") as XROrigin3D
@onready var _pointer := _user.get_node("RightHand/FunctionPointer") as XRToolsFunctionPointer
@onready var _pointer_raycast := _user.get_node("RightHand/FunctionPointer/RayCast") as RayCast3D

@onready var _creator_menu_holder := $CreatorMenuHolder
@onready var _creator_menu_viewport_in_3D := $CreatorMenuHolder/CreatorMenuViewportIn3D
@onready var _creator_menu_content := _creator_menu_viewport_in_3D.get_scene_instance() as FB_CreatorMenuContent

@onready var prompt_creator := $FB_PromptCreator as FB_PromptCreator

var _placement_object: FB_AssetBase = null
var _placement_zone: FB_Zone = null
var _hovered_object: FB_AssetBase = null
var _hovered_zone: FB_Zone = null
var _hovered_zone_extrusion_data = null

@export var saved_assets_to_load: Array[FB_SavedAsset] = []
@export var saved_zones_to_load: Array[FB_SavedZone] = []

var _is_recording := false
@export var recorded_steps: Array[FB_Step] = []
var pre_recording_level_snapshot : FB_Level = null


func _ready() -> void:
	add_to_group("FB_CreatorManager_Group")
	
	if not _user == null:
		# Connect to signals from the controllers.
		_user.get_node("LeftHand").button_pressed.connect(_on_left_hand_button_pressed)
		_user.get_node("LeftHand").button_released.connect(_on_left_hand_button_released)
		_user.get_node("RightHand").button_pressed.connect(_on_right_hand_button_pressed)
		_user.get_node("RightHand").button_released.connect(_on_right_hand_button_released)
	
	if not _creator_menu_content == null:
		# By default, hide the creator menu.
		hide_menu_content()
		
		# Connect to signals from the creator menu.
		_creator_menu_content.object_selected.connect(_begin_placing_object)
		_creator_menu_content.zone_selected.connect(_begin_placing_zone)
		_creator_menu_content.quit_to_main_menu.connect(_quit_to_main_menu)
		_creator_menu_content.start_recording.connect(_start_recording)
		
		# Set default tooltip.
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
	
	# Hide prompt creator until it's needed.
	reset_prompt_creator()
	
	# Reset the object IDs for this session.
	FB_Globals.reset_next_object_ID()
	
	# Load all assets.
	for saved_asset in saved_assets_to_load:
		var asset := FB_SavedAsset.deserialize_asset(saved_asset)
		add_child(asset)
		FB_Globals.NEXT_OBJECT_ID = maxi(FB_Globals.NEXT_OBJECT_ID, asset.object_ID + 1)
	
	# Load all zones.
	for saved_zone in saved_zones_to_load:
		var zone := FB_SavedZone.deserialize_zone(saved_zone)
		add_child(zone)
	
	# Update the UI to show all the steps.
	_creator_menu_content.recorded_steps.text = "<No Recorded Steps>" if recorded_steps.is_empty() else ""
	for step in recorded_steps:
		_creator_menu_content.recorded_steps.text += "\n" + step.step_description


func _process(_delta: float) -> void:
	if not _user == null:
		# Position the creator menu in front of the user.
		_creator_menu_holder.position = _user.position - Plane.PLANE_XZ.project(_user.basis.z) * 1.25 + Vector3.UP*1.5
		_creator_menu_holder.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))
		prompt_creator.position = _user.position - Plane.PLANE_XZ.project(_user.basis.z) * 1.25 + Vector3.UP*1.5
		prompt_creator.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))
	
	if _is_recording:
		return
	
	if not _placement_object == null:
		_update_placing_object()
	elif not _placement_zone == null:
		_update_placing_zone()
	else:
		_update_hovered_objects_and_zones()


func _on_left_hand_button_pressed(button_name: String) -> void:
	if _is_recording:
		return
	
	# Toggle visibility of the creator menu.
	# (Cannot enter the menu while placing an object or a zone.)
	if button_name == "ax_button":
		if not _creator_menu_content == null and _placement_object == null and _placement_zone == null:
			if _creator_menu_viewport_in_3D.enabled:
				hide_menu_content()
			else:
				show_menu_content()


func _on_left_hand_button_released(_button_name: String) -> void:
	return # (Does nothing for now.)


func _on_right_hand_button_pressed(button_name: String) -> void:
	if _is_recording:
		# If recording, no other "edit" actions can be done, other than to finish the recording.
		if button_name == "by_button":
			_end_recording()
		return
	
	# Finalize placement of the current object or of the current zone marker.
	# If a zone is being hovered, press the trigger to extrude.
	if button_name == "trigger_click":
		if _placement_object:
			_try_placing_object()
		elif _placement_zone:
			_try_placing_zone_marker()
		elif _hovered_zone:
			_hovered_zone_extrusion_data = Vector2(_pointer_raycast.global_position.y, _hovered_zone.zone_height)
	
	# Finalize placement of the zone.
	if button_name == "grip_click":
		if _placement_zone:
			_try_placing_zone()
	
	# Cancel the placement of the object/zone or remove the hovered object/zone.
	if button_name == "by_button":
		if _placement_object:
			_handle_object_removel(_placement_object)
			_placement_object = null
			_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
		elif _placement_zone:
			_placement_zone.queue_free()
			_placement_zone = null
			_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
		elif _hovered_object:
			_handle_object_removel(_hovered_object)
			_hovered_object = null
			_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
		elif _hovered_zone:
			_hovered_zone.queue_free()
			_hovered_zone = null
			_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _on_right_hand_button_released(button_name: String) -> void:
	if _is_recording:
		return
	
	# If a zone is being extruded, release the trigger to finish.
	if button_name == "trigger_click":
		_hovered_zone_extrusion_data = null


func _begin_placing_object(asset_file_path: String) -> void:
	# Hide the menu & add object placement tooltip.
	hide_menu_content()
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.OBJECT_PLACEMENT_TOOLTIP)
	
	# Initialize the object & set the file path (for save).
	_placement_object = load(asset_file_path).instantiate()
	_placement_object.asset_file_path = asset_file_path
	
	if not _placement_object:
		push_error("Failed to load object! (Does the asset inherit from FB_AssetBase?)")
		return
	
	# Place the object into the world.
	_placement_object.enter_placement_mode()
	_placement_object.visible = false
	add_child(_placement_object)


func _update_placing_object() -> void:
	if _pointer_raycast.is_colliding() and not _pointer.last_collided_at == null:
		_placement_object.visible = true
		
		var collision_normal := _pointer_raycast.get_collision_normal().normalized()
		var collision_point := _pointer.last_collided_at
		
		_placement_object.position = collision_point + collision_normal * 0.1
		_placement_object.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))
	
	else:
		_placement_object.visible = false


func _try_placing_object() -> void:
	if _placement_object and _placement_object.visible:
		_placement_object.exit_placement_mode()
		_placement_object = null
		
		# Set default tooltip.
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _begin_placing_zone(zone_index: int) -> void:
	# Hide the menu & add zone placement tooltip.
	hide_menu_content()
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.ZONE_PLACEMENT_TOOLTIP)
	
	# Add the placement zone and the first marker.
	_placement_zone = FB_Zone.new(FB_Globals.ZONE_ID_TO_COLOR[zone_index])
	var initial_zone_marker := FB_CreatorManager.make_zone_marker(
		FB_Globals.ZONE_ID_TO_COLOR[zone_index])
	initial_zone_marker.visible = false
	_placement_zone.add_child(initial_zone_marker)
	add_child(_placement_zone)


func _update_placing_zone() -> void:
	var cur_zone_marker = _placement_zone.get_child(_placement_zone.get_child_count() - 1)
	
	# For the first zone marker, we collide directly with the level geometry.
	if _placement_zone.get_child_count() == 1:
		if _pointer_raycast.is_colliding() and not _pointer.last_collided_at == null:
			cur_zone_marker.visible = true
			cur_zone_marker.position = _pointer.last_collided_at
		else:
			cur_zone_marker.visible = false
	
	# For the next zone markers, we restrict placement to an XZ plane aligned with the first marker.
	else:
		var zone_plane := Plane(Vector3.UP, _placement_zone.get_child(0).position)
		var collision = zone_plane.intersects_ray(
			_pointer_raycast.global_position,
			_pointer_raycast.global_basis.z * -1)
		if not collision == null:
			cur_zone_marker.visible = true
			cur_zone_marker.position = collision
		else:
			cur_zone_marker.visible = false


func _try_placing_zone_marker() -> void:
	if _placement_zone:
		var cur_zone_marker = _placement_zone.get_child(_placement_zone.get_child_count() - 1)
		var zone_is_okay := _placement_zone.get_child_count() < 3 or _placement_zone.check_zone()
		
		if cur_zone_marker.visible and zone_is_okay:
			var next_zone_marker := FB_CreatorManager.make_zone_marker(
				cur_zone_marker.mesh.material.albedo_color)
			next_zone_marker.visible = false
			_placement_zone.add_child(next_zone_marker)


func _try_placing_zone() -> void:
	if _placement_zone:
		var doomed_zone_marker = _placement_zone.get_child(_placement_zone.get_child_count() - 1)
		_placement_zone.remove_child(doomed_zone_marker)
		doomed_zone_marker.queue_free()
		
		var zone_is_valid := _placement_zone.check_zone()
		if zone_is_valid:
			_placement_zone.commit_zone()
			_placement_zone = null
		else:
			_placement_zone.queue_free()
			_placement_zone = null
		
		# Set default tooltip.
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _update_hovered_objects_and_zones() -> void:
	_hovered_object = null
	_hovered_zone = null
	
	# Set default tooltip.
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
	
	if _pointer_raycast.is_colliding() and not _pointer.last_collided_at == null:
		var collider := _pointer_raycast.get_collider()
		
		if collider and (collider.get_parent() and collider.get_parent() is FB_AssetBase):
			_hovered_object = collider.get_parent() as FB_AssetBase
		
		elif collider and (collider.get_parent() and collider.get_parent() is FB_Zone):
			_hovered_zone = collider.get_parent() as FB_Zone
	
	if _hovered_object:
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.OBJECT_HOVERED_TOOLTIP)
	elif _hovered_zone:
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.ZONE_HOVERED_TOOLTIP)
		
		# Handle zone height extrusion.
		if _hovered_zone_extrusion_data != null:
			_hovered_zone.zone_height = _hovered_zone_extrusion_data.y + 2 * (
				_pointer_raycast.global_position.y - _hovered_zone_extrusion_data.x)
			_hovered_zone.update_zone(true)


func _quit_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _start_recording() -> void:
	_is_recording = true
	recorded_steps = []
	_creator_menu_content.recorded_steps.text = "<No Recorded Steps>"
	_creator_menu_content.recorded_steps_icon.visible = true
	
	# Hide the menu & add default tooltip.
	hide_menu_content()
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.RECORDING_TOOLTIP)
	
	pre_recording_level_snapshot = FB_LevelManagerInstance.get_level_snapshot()


func _end_recording() -> void:
	_is_recording = false
	_creator_menu_content.recorded_steps_icon.visible = false
	
	# Hide the menu & add default tooltip.
	hide_menu_content()
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
	
	# We've recorded some steps. Move these over to the level snapshot we
	# saved before the recording, then reload the level. This ensures that
	# objects go back to their initial positions/configurations.
	pre_recording_level_snapshot.steps = recorded_steps.duplicate(true)
	FB_LevelManagerInstance.edit_level_directly(pre_recording_level_snapshot)


# Function to fix a bug when freeing objects which have snap zones
func _handle_object_removel(object: FB_AssetBase) -> void:
	# drop all objects currently in the snap zones
	for snap_zone in object.pickable_object.get_children():
		if (snap_zone.has_method("is_xr_class") && snap_zone.is_xr_class("XRToolsSnapZone")):
			snap_zone.enabled = false
			snap_zone.drop_object()
	object.queue_free()


func try_recording_step(step: FB_Step) -> void:
	if not _is_recording:
		return
	
	if _creator_menu_content.recorded_steps.text == "<No Recorded Steps>":
		_creator_menu_content.recorded_steps.text = ""
	
	_creator_menu_content.recorded_steps.text += "\n" + step.step_description
	recorded_steps.push_back(step)


func show_menu_content() -> void:
	_creator_menu_content.set_menu_visibility(true)
	_creator_menu_viewport_in_3D.enabled = true


func hide_menu_content() -> void:
	_creator_menu_content.set_menu_visibility(false)
	_creator_menu_viewport_in_3D.enabled = false


func show_prompt_creator(headerVal: String = "Enter a File Name:") -> void:
	prompt_creator.set_header_text(headerVal)
	prompt_creator.visible = true
	prompt_creator.enable()
	
	# Also completely hide the creator menu.
	_creator_menu_content.visible = false


func reset_prompt_creator() -> void:
	prompt_creator.reset()
	prompt_creator.visible = false
	prompt_creator.disable()
	prompt_creator.disconnect_all()
	
	# Show the creator menu again.
	_creator_menu_content.visible = true


static func align_with_normal(xform: Transform3D, normal: Vector3) -> Transform3D:
	xform.basis.y = normal.normalized()
	xform.basis.x = -xform.basis.z.cross(xform.basis.y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform


static func make_zone_marker(zone_color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.mesh.radius = 0.05
	mesh_instance.mesh.height = 0.1
	mesh_instance.mesh.material = StandardMaterial3D.new()
	mesh_instance.mesh.material.albedo_color = zone_color
	mesh_instance.mesh.material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	return mesh_instance
