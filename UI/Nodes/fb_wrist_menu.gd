extends Node3D

var is_shown : bool = true: set = set_is_shown

var tab_item: PackedScene = preload("res://UI/Controls/fb_wrist_menu_tab_item.tscn")

@onready var menu_content: CanvasLayer = $Menu.get_scene_instance()

func _ready() -> void:
	_populate_objects()
	_populate_zones()


func set_is_shown(shown: bool) -> void:
	is_shown = shown

# Here we need to make a function that will act as the callback for all of
# the tab item buttons we are making. Maybe a different implementation for
# zones and objects.

# func on_zone_item_selected()

# func on_object_item_selected()

# Need to decide where we are actually going to pull these items from

func _populate_objects() -> void:
	var texture = load("res://icon.svg")
	
	for file in DirAccess.get_files_at("res://Assets/"):
		if file.get_extension() == "import":
			file = file.replace('.import','')
		var new_tab_item = tab_item.instantiate()
		new_tab_item.set_button_text(file)
		new_tab_item.set_button_icon(texture)
		# new_tab_item.set_button_callback(on_object_item_selected)
		menu_content.add_item_to_tabs_list(new_tab_item, "objects")

func _populate_zones() -> void:
	var texture = load("res://icon.svg")
	
	for file in DirAccess.get_files_at("res://Assets/"):
		if file.get_extension() == "import":
			file = file.replace('.import','')
		var new_tab_item = tab_item.instantiate()
		new_tab_item.set_button_text(file)
		new_tab_item.set_button_icon(texture)
		# new_tab_item.set_button_callback(on_zone_item_selected)
		menu_content.add_item_to_tabs_list(new_tab_item, "zones")
