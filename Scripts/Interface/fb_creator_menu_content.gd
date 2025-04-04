class_name FB_CreatorMenuContent extends Control

# This node will be instantiated by a "Viewport 2D in 3D" node.
# This script should contain internal logic for the UI and expose certain
# buttons/signals that can be connected to from the owning 3D scene.

signal object_selected
signal zone_selected
signal quit_to_main_menu
signal start_recording

@onready var _tooltip := $Tooltip
@onready var _tooltip_label := $Tooltip/TooltipLabel
@onready var _creator_menu := $CreatorMenu
@onready var _objects_menu := $"CreatorMenu/CreatorMenuMarginBox/MainTabs/Object Placement/ObjectsMenu"
@onready var _zones_menu := $"CreatorMenu/CreatorMenuMarginBox/MainTabs/Zone Placement/ZonesMenu"
@onready var recorded_steps := $RecordingMenu/MarginContainer/VBoxContainer/RecordedSteps
@onready var recorded_steps_icon := $RecordingMenu/MarginContainer/VBoxContainer/HBoxContainer/RecordedStepsIcon

const DEFAULT_TOOLTIP = "  (Press X to show/hide the menu.)  "
const OBJECT_PLACEMENT_TOOLTIP = "  Press R. TRIGGER to place object.  \n  Press B to cancel.  \n"
const OBJECT_HOVERED_TOOLTIP = "  Press B to delete object.  \n" + DEFAULT_TOOLTIP
const ZONE_PLACEMENT_TOOLTIP = "  Press R. TRIGGER to add zone vertices.  \n  Press R. GRIP to finish zone.  \n  Press B to cancel.  \n"
const ZONE_HOVERED_TOOLTIP = "  Press and hold R. TRIGGER to extrude zone.  \n  Press B to delete zone.  \n" + DEFAULT_TOOLTIP
const RECORDING_TOOLTIP = "  Currently recording. Press B to finish."


func _ready() -> void:
	const OBJECT_BUTTON := preload("res://Scenes/Interface/fb_creator_menu_object_button.tscn")
	for object_file_name in DirAccess.get_files_at("res://Assets"):
		var new_object_button := OBJECT_BUTTON.instantiate() as Button
		new_object_button.text = object_file_name.trim_prefix("fb_").trim_suffix(".remap").trim_suffix(".tscn").capitalize()
		new_object_button.pressed.connect(_on_object_button_pressed.bind("res://Assets/" + object_file_name.trim_suffix(".remap")))
		_objects_menu.add_child(new_object_button)
	
	for zone_button_idx in _zones_menu.get_child_count():
		_zones_menu.get_child(zone_button_idx).modulate = FB_Globals.ZONE_ID_TO_COLOR[zone_button_idx]


func set_menu_visibility(new_is_visible: bool) -> void:
	_tooltip.visible = not new_is_visible
	_creator_menu.visible = new_is_visible


func set_tooltip(tooltip: StringName) -> void:
	_tooltip_label.text = tooltip


func _on_object_button_pressed(object_file_path: StringName) -> void:
	object_selected.emit(object_file_path)
	print("<debug> Selected object '%s'." % object_file_path)


func _on_zone_button_pressed(zone_number: int) -> void:
	zone_selected.emit(zone_number)
	print("<debug> Selected zone %d." % zone_number)


func _on_quit_to_main_menu_button_pressed() -> void:
	quit_to_main_menu.emit()
	print("<debug> Quitting to main menu.")


func _on_save_level_button_pressed() -> void:
	var creator_manager: FB_CreatorManager = get_tree().get_first_node_in_group("FB_CreatorManager_Group")
	
	# If this is the tutorial manager, don't allow saving
	if creator_manager is FB_TutorialManager:
		return
	
	creator_manager.hide_menu_content()
	
	var handle_cancel := func():
		creator_manager.reset_prompt_creator()
	
	var handle_name_done := func(level_name: String):
		
		var handle_description_done := func(level_description: String):
			FB_LevelManagerInstance._loaded_level.description = level_description
			FB_LevelManagerInstance.save_level(level_name)
			creator_manager.reset_prompt_creator()
		
		creator_manager.reset_prompt_creator()
		creator_manager.show_prompt_creator("Enter a Level Description")
		creator_manager.prompt_creator.user_pressed_done.connect(handle_description_done)
		creator_manager.prompt_creator.user_pressed_cancel.connect(handle_cancel)
	
	creator_manager.show_prompt_creator("Enter a Level Name")
	creator_manager.prompt_creator.user_pressed_done.connect(handle_name_done)
	creator_manager.prompt_creator.user_pressed_cancel.connect(handle_cancel)


func _on_start_recording_button_pressed():
	start_recording.emit()


func _on_back_button_pressed():
	var creator_manager: FB_CreatorManager = get_tree().get_first_node_in_group("FB_CreatorManager_Group")
	creator_manager.hide_menu_content()
