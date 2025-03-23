# This is a container class to store globals needed for scripts and resources.
# All members here can be referenced from any script by FB_Globals.[name]
# This uses an autoload singleton described in the project settings.

class_name Globals extends Node

# (The player body always has the object ID of 0.)
var NEXT_OBJECT_ID: int = 1

func reset_next_object_ID() -> void:
	NEXT_OBJECT_ID = 1

enum StepType {
	ZONE_ENTERED,
	ZONE_EXITED,
	OBJECT_INTERACT
}

const ZONE_ID_TO_COLOR = {
	0: Color.WHITE,
	1: Color.LIGHT_SLATE_GRAY,
	2: Color.LIGHT_SKY_BLUE,
	3: Color.LIGHT_GREEN,
	4: Color.ORANGE,
	5: Color.ORANGE_RED,
	6: Color.MEDIUM_PURPLE,
	7: Color.SLATE_GRAY
}

const ZONE_ID_TO_COLOR_NAME = {
	0: "White",
	1: "Light Gray",
	2: "Blue",
	3: "Green",
	4: "Orange",
	5: "Red",
	6: "Purple",
	7: "Dark Gray"
}

func get_zone_ID_from_color(color: Color) -> int:
	if color.is_equal_approx(Color.WHITE):
		return 0
	if color.is_equal_approx(Color.LIGHT_SLATE_GRAY):
		return 1
	if color.is_equal_approx(Color.LIGHT_SKY_BLUE):
		return 2
	if color.is_equal_approx(Color.LIGHT_GREEN):
		return 3
	if color.is_equal_approx(Color.ORANGE):
		return 4
	if color.is_equal_approx(Color.ORANGE_RED):
		return 5
	if color.is_equal_approx(Color.MEDIUM_PURPLE):
		return 6
	if color.is_equal_approx(Color.SLATE_GRAY):
		return 7
	
	return -1
