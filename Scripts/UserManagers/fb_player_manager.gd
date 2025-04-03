class_name FB_PlayerManager extends Node3D


@onready var _user := get_parent().get_node("XROrigin3D") as XROrigin3D

@onready var _player_menu_holder := $PlayerMenuHolder
@onready var _player_menu_viewport_in_3D := $PlayerMenuHolder/PlayerMenuViewportIn3D
@onready var _player_menu_content := _player_menu_viewport_in_3D.get_scene_instance() as FB_PlayerMenuContent

@export var saved_assets_to_load: Array[FB_SavedAsset] = []
@export var saved_zones_to_load: Array[FB_SavedZone] = []
@export var recorded_steps: Array[FB_Step] = []
var completed_step_cursor := 0


func _ready() -> void:
	add_to_group("FB_PlayerManager_Group")
	
	if not _user == null:
		# Connect to signals from the controllers.
		_user.get_node("LeftHand").button_pressed.connect(_on_left_hand_button_pressed)
		_user.get_node("LeftHand").button_released.connect(_on_left_hand_button_released)
		_user.get_node("RightHand").button_pressed.connect(_on_right_hand_button_pressed)
		_user.get_node("RightHand").button_released.connect(_on_right_hand_button_released)
	
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
	_player_menu_content.steps_label.text = ""
	for step in recorded_steps:
		if _player_menu_content.steps_label.text == "":
			_player_menu_content.steps_label.text += step.step_description
		else:
			_player_menu_content.steps_label.text += "\n" + step.step_description
	
	# Set name and description on UI - this is terrible ...
	_player_menu_content.name_label.text = FB_LevelManagerInstance._loaded_level.display_name
	_player_menu_content.description_label.text = FB_LevelManagerInstance._loaded_level.description


func _process(_delta: float) -> void:
	if not _user == null:
		# Position the creator menu in front of the user.
		_player_menu_holder.position = _user.position - Plane.PLANE_XZ.project(_user.basis.z) * 1.25 + Vector3.UP
		_player_menu_holder.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))


func _on_left_hand_button_pressed(_button_name: String) -> void:
	return # (Does nothing for now.)


func _on_left_hand_button_released(_button_name: String) -> void:
	return # (Does nothing for now.)


func _on_right_hand_button_pressed(_button_name: String) -> void:
	return # (Does nothing for now.)


func _on_right_hand_button_released(_button_name: String) -> void:
	return # (Does nothing for now.)


func try_completing_step(step: FB_Step) -> void:
	if completed_step_cursor >= recorded_steps.size():
		return # All steps are complete!
	
	if step.is_equal_to(recorded_steps[completed_step_cursor]):
		
		# Redraw steps to cross out completed ones.
		_player_menu_content.steps_label.text = ""
		for step_idx in recorded_steps.size():
			var cur_step = recorded_steps[step_idx]
			var pre = "[s]" if step_idx <= completed_step_cursor else ""
			var post = "[/s]" if step_idx <= completed_step_cursor else ""
			if _player_menu_content.steps_label.text == "":
				_player_menu_content.steps_label.text += pre + cur_step.step_description + post
			else:
				_player_menu_content.steps_label.text += "\n" + pre + cur_step.step_description + post
		
		completed_step_cursor += 1
