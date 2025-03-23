class_name FB_SavedZone extends Resource

# Represents a persistent zone in a saved Fishbowl level.

@export var zone_transform: Transform3D
@export var zone_height := 0.25
@export var zone_vertices := PackedVector2Array()
@export var zone_y_level := 0.00
@export var zone_color := Color.WHITE


static func serialize_zone(zone: FB_Zone) -> FB_SavedZone:
	var saved_zone := FB_SavedZone.new()
	saved_zone.zone_transform = zone.global_transform
	saved_zone.zone_height = zone.zone_height
	saved_zone.zone_vertices = zone._zone_vertices
	saved_zone.zone_y_level = zone._zone_y_level
	saved_zone.zone_color = zone._zone_color
	return saved_zone


static func deserialize_zone(saved_zone: FB_SavedZone) -> FB_Zone:
	var zone := FB_Zone.new(saved_zone.zone_color)
	zone.transform = saved_zone.zone_transform
	zone.zone_height = saved_zone.zone_height
	zone._zone_vertices = saved_zone.zone_vertices
	zone._zone_y_level = saved_zone.zone_y_level
	zone._zone_is_committed = true
	zone.update_zone(true, true)
	return zone
