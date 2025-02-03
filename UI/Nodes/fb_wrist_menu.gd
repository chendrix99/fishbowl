extends Node3D

@onready var menu_content: CanvasLayer = $Menu.get_scene_instance()

var is_shown : bool = true: set = set_is_shown

var tab_item: PackedScene = preload("res://UI/Controls/fb_wrist_menu_tab_item.tscn")

var object_callback: Callable

var zone_callback: Callable

# ------------------------------------------------------------------------------
func set_is_shown(shown: bool) -> void:
	is_shown = shown

# Need to decide where we are actually going to pull these items from
# While this behavior is the same for now, it may diverge so wait to
# combine these functions until later.
func populate_objects(path: String) -> void:
	var texture = load("res://icon.svg")
	
	for file in DirAccess.get_files_at(path):
		if file.get_extension() == "import":
			file = file.replace('.import','')
		var new_tab_item = tab_item.instantiate()
		new_tab_item.set_button_text(file)
		new_tab_item.set_asset_file_name(file)
		new_tab_item.set_button_icon(texture)
		new_tab_item.set_button_callback(object_callback)
		menu_content.add_item_to_tabs_list(new_tab_item, "objects")

func populate_zones(path: String) -> void:
	var texture = load("res://icon.svg")
	
	for file in DirAccess.get_files_at(path):
		if file.get_extension() == "import":
			file = file.replace('.import','')
		var new_tab_item = tab_item.instantiate()
		new_tab_item.set_button_text(file)
		new_tab_item.set_asset_file_name(file)
		new_tab_item.set_button_icon(texture)
		new_tab_item.set_button_callback(zone_callback)
		menu_content.add_item_to_tabs_list(new_tab_item, "zones")
