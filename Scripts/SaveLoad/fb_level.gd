class_name FB_Level extends Resource

# The FB Level contains all information needed to save/load a scene.

## The level's user-facing title.
@export var display_name : StringName

## The level's description.
@export var description : StringName

## The level "template" is a packed scene containing the player (XROrigin3D) and environment.
@export var template : PackedScene

## The level's assets (blocks, buttons, etc.)
@export var saved_assets : Array[FB_SavedAsset]

## The level's zones.
@export var saved_zones : Array[FB_SavedZone]

## The level's recorded steps.
@export var steps : Array[FB_Step]
