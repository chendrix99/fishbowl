class_name FB_AssetBase extends Node3D

# Note: All FB assets should inherit from this script directly!
# This script is required to make placement possible.

@export var pickable_object: XRToolsPickable


func _ready() -> void:
	if not pickable_object == get_child(0):
		push_error("Asset configuration is invalid! Child #0 must be an XRToolsPickable node.")


func _process(_delta: float) -> void:
	# This is a really dumb hack. For some reason, when you pick up an object,
	# it resets the collision layer. But we need bit 20 to be set so that the
	# creator can "hover" the object and delete it.
	if pickable_object and pickable_object.enabled:
		pickable_object.collision_layer |= 1 << 20


func enter_placement_mode() -> void:
	pickable_object.enabled = false
	pickable_object.freeze = true
	pickable_object.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC


func exit_placement_mode() -> void:
	pickable_object.enabled = true
	pickable_object.freeze = false
	pickable_object.linear_velocity = Vector3()
	pickable_object.angular_velocity = Vector3()
