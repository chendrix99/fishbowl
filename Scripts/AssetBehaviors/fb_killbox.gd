class_name FB_Killbox extends Area3D

# This class simply moves the player to a pre-defined location if they enter the
# attached collision shape. Should be used to prevent them from falling infinitely.

@export var respawn_point : Vector3


func _ready() -> void:
	collision_layer = 256 # (Layer 9)
	collision_mask = 524288 # (Layer "Player Body")
	body_entered.connect(_body_entered)


func _body_entered(body: Node3D) -> void:
	if body is XRToolsPlayerBody:
		body.get_parent().position = respawn_point
