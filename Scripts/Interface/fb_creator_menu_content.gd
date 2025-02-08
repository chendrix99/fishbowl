class_name FB_CreatorMenuContent extends Control


# This node will be instantiated by a "Viewport 2D in 3D" node.
# This script should contain internal logic for the UI and expose certain
# buttons/signals that can be connected to from the owning 3D scene.


signal object_selected
signal zone_selected
signal quit_to_main_menu

@onready var _tooltip := $Tooltip
@onready var _tooltip_label := $Tooltip/TooltipLabel
@onready var _creator_menu := $CreatorMenu
@onready var _objects_menu := $CreatorMenu/MarginContainer/Body/ObjectsMenu
@onready var _zones_menu := $CreatorMenu/MarginContainer/Body/ZonesMenu

const DEFAULT_TOOLTIP = "  (Press X to show/hide the menu.)  "
const OBJECT_PLACEMENT_TOOLTIP = "  Press R. TRIGGER to place.  \n  Press R. GRIP to cancel.  \n" + DEFAULT_TOOLTIP
const ZONE_PLACEMENT_TOOLTIP = DEFAULT_TOOLTIP


func set_menu_visibility(is_visible: bool) -> void:
	_tooltip.visible = not is_visible
	_creator_menu.visible = is_visible
	
	_objects_menu.visible = true
	_zones_menu.visible = false


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


func _ready() -> void:
	const object_button := preload("res://Scenes/Interface/fb_creator_menu_object_button.tscn")
	for object_file_name in DirAccess.get_files_at("res://Assets"):
		var new_object_button := object_button.instantiate() as Button
		new_object_button.text = object_file_name.trim_suffix(".tscn").capitalize()
		new_object_button.pressed.connect(_on_object_button_pressed.bind("res://Assets/" + object_file_name))
		_objects_menu.add_child(new_object_button)


func _on_objects_button_pressed():
	_objects_menu.visible = true
	_zones_menu.visible = false


func _on_zones_button_pressed():
	_objects_menu.visible = false
	_zones_menu.visible = true
