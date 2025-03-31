class_name FB_PlayerManager extends Node3D

@onready var _user := get_parent().get_node("XROrigin3D") as XROrigin3D
@onready var _pointer := _user.get_node("RightHand/FunctionPointer") as XRToolsFunctionPointer
@onready var _pointer_raycast := _user.get_node("RightHand/FunctionPointer/RayCast") as RayCast3D

@onready var _player_menu_holder := $PlayerMenuHolder
@onready var _player_menu_viewport_in_3D := $PlayerMenuHolder/PlayerMenuViewportIn3D
@onready var _player_menu_content := _player_menu_viewport_in_3D.get_scene_instance() as FB_PlayerMenuContent

func _ready() -> void:
	add_to_group("FB_PlayerManager_Group")
	
	if not _user == null:
		#Connect to signals from the controllers.
		_user.get_node("LeftHand").button_pressed.connect(_on_left_hand_button_pressed)
		_user.get_node("LeftHand").button_released.connect(_on_left_hand_button_released)
		_user.get_node("RightHand").button_pressed.connect(_on_right_hand_button_pressed)
		_user.get_node("RightHand").button_released.connect(_on_right_hand_button_released)
		
	if not _player_menu_content == null:
		#By default, hide the creator menu.
		hide_menu_content()
		
		#Connect to signals from the creator menu.
		_player_menu_content.quit_to_main_menu.connect(_quit_to_main_menu)
		_player_menu_content.restart_level.connect(_restart_level)
		
		#Set default tooltip.
		_player_menu_content.set_tooltip(FB_PlayerMenuContent.DEFAULT_TOOLTIP)
		
func _process(_delta: float) -> void:
	if not _user == null:
		# Position the creator menu in front of the user.
		_player_menu_holder.position = _user.position - Plane.PLANE_XZ.project(_user.basis.z) * 1.25 + Vector3.UP
		_player_menu_holder.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))
		
func _on_left_hand_button_pressed(button_name: String) -> void:
	#toggle visibility of player menu
	if button_name == "ax_button":
		var menu_is_visible = _player_menu_viewport_in_3D.enabled
		_player_menu_content.set_menu_visibility(not menu_is_visible)
		_player_menu_viewport_in_3D.enabled = not menu_is_visible
	
func _on_left_hand_button_released(button_name: String) -> void:
	return
	
func _on_right_hand_button_pressed(button_name: String) -> void:
	return
	
func _on_right_hand_button_released(button_name: String) -> void:
	return
	
func hide_menu_content() -> void:
	_player_menu_content.set_menu_visibility(false)
	_player_menu_viewport_in_3D.enabled = false
	
func _restart_level() -> void:
	var current_scene = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(current_scene)
	
func _quit_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/main.tscn")
