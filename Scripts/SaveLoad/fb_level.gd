class_name FB_Level extends Resource

# The FB Level contains all information needed to save/load a scene.

## The level's user-facing title.
@export var display_name : StringName

## The level "template" is a packed scene containing the player (XROrigin3D) and environment.
@export var template : PackedScene
