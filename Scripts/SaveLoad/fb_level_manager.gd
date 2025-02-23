class_name FB_LevelManager extends Node

var _loaded_level : FB_Level = null

const CREATOR_MANAGER := preload("res://Scenes/UserManagers/fb_creator_manager.tscn")
const PLAYER_MANAGER := preload("res://Scenes/UserManagers/fb_player_manager.tscn")

const LEVEL_TEMPLATE_DIRECTORY := "res://Assets/LevelTemplates/"
const LEVEL_SAVES_DIRECTORY := "user://LevelSaves/"


func create_level(level_template_file_path: String) -> void:
	var new_level = FB_Level.new()
	
	new_level.display_name = "New Level"
	new_level.template = load(level_template_file_path)
	
	_edit_level_internal(new_level)


func edit_level(level_file_path: String) -> void:
	var level = load(level_file_path)
	if not level == null and level is FB_Level:
		_edit_level_internal(level)
	else:
		push_error("Failed to open level: %s" % level_file_path)


func _edit_level_internal(level: FB_Level) -> void:
	_loaded_level = level
	
	# First instantiate the level template.
	var level_template_instance = _loaded_level.template.instantiate()
	
	# Next instantiate the Creator Manager and add it to the scene.
	var creator_manager = CREATOR_MANAGER.instantiate()
	level_template_instance.add_child(creator_manager)
	creator_manager.owner = level_template_instance
	
	# Finally, re-pack the scene and load the level.
	var packed_scene := PackedScene.new()
	packed_scene.pack(level_template_instance)
	get_tree().change_scene_to_packed(packed_scene)


func play_level(level_file_path: String) -> void:
	var level = load(level_file_path)
	if not level == null and level is FB_Level:
		_play_level_internal(level)
	else:
		push_error("Failed to open level: %s" % level_file_path)


func _play_level_internal(level: FB_Level) -> void:
	_loaded_level = level
	
	# First instantiate the level template.
	var level_template_instance = _loaded_level.template.instantiate()
	
	# Next instantiate the Player Manager and add it to the scene.
	var player_manager = PLAYER_MANAGER.instantiate()
	level_template_instance.add_child(player_manager)
	player_manager.owner = level_template_instance
	
	# Finally, re-pack the scene and load the level.
	var packed_scene := PackedScene.new()
	packed_scene.pack(level_template_instance)
	get_tree().change_scene_to_packed(packed_scene)


func save_level(display_name: StringName = "Untitled Level") -> void:
	if _loaded_level == null:
		push_error("Cannot save level! No level is loaded!")
		return
	
	var saved_level := FB_Level.new()
	
	saved_level.display_name = display_name
	saved_level.template = _loaded_level.template
	
	var file_path = LEVEL_SAVES_DIRECTORY + display_name.validate_filename()
	if FileAccess.file_exists(file_path):
		var file_path_suffix := "_%d"
		var file_path_idx := 0
		while FileAccess.file_exists(file_path + file_path_suffix % file_path_idx):
			file_path_idx += 1
		file_path = file_path + file_path_suffix % file_path_idx
	
	ResourceSaver.save(saved_level, file_path + ".tres")
