class_name FB_MainMenuContent extends Control

# This node will be instantiated by a "Viewport 2D in 3D" node.
# This script should contain internal logic for the UI and expose certain
# buttons/signals that can be connected to from the owning 3D scene.

@onready var creator_button := $MainMenuHBox/CreatorButton as Button
@onready var player_button := $MainMenuHBox/PlayerButton as Button
@onready var quit_button := $MainMenuHBox/QuitButton as Button
