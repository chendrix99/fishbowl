class_name FB_MainMenuHolder extends Node3D


@onready var _main_menu_content := $MainMenuViewportIn3D.get_scene_instance() as FB_MainMenuContent


func _ready() -> void:
	if not _main_menu_content == null:
		_main_menu_content.creator_button.pressed.connect(_on_creator_button_pressed)
		_main_menu_content.player_button.pressed.connect(_on_player_button_pressed)
		_main_menu_content.quit_button.pressed.connect(_on_quit_button_pressed)


func _on_creator_button_pressed() -> void:
	# When a level is loaded for the Creator, add the "Creator Manager" scene.
	# This scene includes all functionality that allows Creators to create &
	# edit the level, and to set up steps and procedures.
	
	var default_scene = load("res://Scenes/Level/fb_default_level.tscn").instantiate()
	var creator_manager = load("res://Scenes/User/fb_creator_manager.tscn").instantiate()
	
	default_scene.add_child(creator_manager)
	creator_manager.owner = default_scene
	
	var packed_scene := PackedScene.new()
	packed_scene.pack(default_scene)
	get_tree().change_scene_to_packed(packed_scene)


func _on_player_button_pressed() -> void:
	# Same thing here: We add "Player Manager" to the level we want to load.
	
	var default_scene = load("res://Scenes/Level/fb_default_space.tscn").instantiate()
	var player_manager = load("res://Scenes/User/fb_player_manager.tscn").instantiate()
	
	default_scene.add_child(player_manager)
	player_manager.owner = default_scene
	
	var packed_scene := PackedScene.new()
	packed_scene.pack(default_scene)
	get_tree().change_scene_to_packed(packed_scene)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
