class_name FB_AssetBase extends Node3D


# Note: All FB assets should inherit from this script directly!
# This script is required to make placement possible.


@export var pickable_object: XRToolsPickable


func enter_placement_mode() -> void:
	pickable_object.enabled = false
	pickable_object.freeze = true
	pickable_object.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC


func exit_placement_mode() -> void:
	pickable_object.enabled = true
	pickable_object.freeze = false
	pickable_object.linear_velocity = Vector3()
	pickable_object.angular_velocity = Vector3()
