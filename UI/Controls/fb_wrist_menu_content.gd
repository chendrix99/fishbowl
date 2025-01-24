extends CanvasLayer

# Probably not the best way of doing this but can be refactored later
func add_item_to_tabs_list(item: Control, list: String) -> void:
	if list == "objects":
		$MarginContainer/FBWristMenuTabs.add_to_objects_list(item)
	elif list == "zones":
		$MarginContainer/FBWristMenuTabs.add_to_zones_list(item)
