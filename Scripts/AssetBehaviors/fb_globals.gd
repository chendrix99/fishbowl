# This is a container class to store globals needed for scripts and resources.
# All members here can be referenced from any script by FB_Globals.[name]
# This uses an autoload singleton described in the project settings.

class_name Globals extends Node

var ZONE_ID: int = 0

# The Player Body always has the object id of 1
var OBJECT_ID: int = 1

enum StepType {
	ZONE_ENTERED,
	ZONE_EXITED
}
