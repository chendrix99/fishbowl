extends Control

func add_to_objects_list(tab_item: Control) -> void:
	$TabContainer/Objects/ScrollContainer/ObjectsList.add_child(tab_item)

func add_to_zones_list(tab_item: Control) -> void:
	$TabContainer/Zones/ScrollContainer/ZonesList.add_child(tab_item)
