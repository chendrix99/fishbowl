class_name FB_LevelManager extends Node

var _loaded_level : FB_Level = null

const CREATOR_MANAGER := preload("res://Scenes/UserManagers/fb_creator_manager.tscn")
const PLAYER_MANAGER := preload("res://Scenes/UserManagers/fb_player_manager.tscn")

const LEVEL_TEMPLATE_DIRECTORY := "res://LevelTemplates/"
const LEVEL_SAVES_DIRECTORY := "user://LevelSaves/"


# This function takes the currently loaded level and turns it into an FB_Level.
# Effectively this acts as a save, but not to the disk. We use this to save a
# snapshot of the level before recording, so that we can revert to it after the
# recording is ended. This is also used for save to disk.
func get_level_snapshot(display_name: StringName = "Untitled_Level") -> FB_Level:
	if _loaded_level == null:
		push_error("Cannot save level! No level is loaded!")
		return null
	
	# Step 1. Find the Creator Manager object in the scene tree.
	var creator_manager := get_tree().get_first_node_in_group("FB_CreatorManager_Group")
	if creator_manager == null or not creator_manager is FB_CreatorManager:
		push_error("Cannot save level! FB_CreatorManager was not found!")
		return null
	
	# Step 2. Set up basic level information.
	var saved_level := FB_Level.new()
	saved_level.display_name = display_name
	saved_level.template = _loaded_level.template
	saved_level.steps = creator_manager.recorded_steps.duplicate(true)
	
	# Step 3. Find all assets in the scene & save them.
	for cur_child_node in creator_manager.get_children():
		if cur_child_node is FB_AssetBase:
			saved_level.saved_assets.push_back(FB_SavedAsset.serialize_asset(cur_child_node))
	
	# Step 4. Find all zones in the scene & save them.
	for cur_child_node in creator_manager.get_children():
		if cur_child_node is FB_Zone:
			saved_level.saved_zones.push_back(FB_SavedZone.serialize_zone(cur_child_node))
	
	return saved_level


func create_level(level_template_file_path: String) -> void:
	var new_level = FB_Level.new()
	
	new_level.display_name = "New Level"
	new_level.template = load(level_template_file_path)
	
	edit_level_directly(new_level)


func edit_level(level_file_path: String) -> void:
	var level = load(level_file_path)
	if not level == null and level is FB_Level:
		edit_level_directly(level)
	else:
		push_error("Failed to open level: %s" % level_file_path)


func edit_level_directly(level: FB_Level) -> void:
	_loaded_level = level
	
	# First instantiate the level template.
	var level_template_instance = _loaded_level.template.instantiate()
	
	# Next instantiate the Creator Manager and add it to the scene.
	var creator_manager = CREATOR_MANAGER.instantiate()
	level_template_instance.add_child(creator_manager)
	creator_manager.owner = level_template_instance
	creator_manager.saved_assets_to_load = level.saved_assets
	creator_manager.saved_zones_to_load = level.saved_zones
	creator_manager.recorded_steps = level.steps.duplicate(true)
	
	# Finally, re-pack the scene and load the level.
	var packed_scene := PackedScene.new()
	packed_scene.pack(level_template_instance)
	get_tree().change_scene_to_packed(packed_scene)


func play_level(level_file_path: String) -> void:
	var level = load(level_file_path)
	if not level == null and level is FB_Level:
		play_level_directly(level)
	else:
		push_error("Failed to open level: %s" % level_file_path)


func play_level_directly(level: FB_Level) -> void:
	_loaded_level = level
	
	# First instantiate the level template.
	var level_template_instance = _loaded_level.template.instantiate()
	
	# Next instantiate the Player Manager and add it to the scene.
	var player_manager = PLAYER_MANAGER.instantiate()
	level_template_instance.add_child(player_manager)
	player_manager.owner = level_template_instance
	
	# Now instantiate all assets/zones under the player manager.
	for saved_asset in level.saved_assets:
		player_manager.add_child(FB_SavedAsset.deserialize_asset(saved_asset))
	
	# Finally, re-pack the scene and load the level.
	var packed_scene := PackedScene.new()
	packed_scene.pack(level_template_instance)
	get_tree().change_scene_to_packed(packed_scene)


func save_level(display_name: StringName = "Untitled_Level") -> void:
	var saved_level := get_level_snapshot(display_name)
	
	if saved_level == null:
		return
	
	# Save the level with a unique file path.
	var file_path = LEVEL_SAVES_DIRECTORY + display_name.validate_filename()
	if FileAccess.file_exists(file_path + ".tres"):
		var file_path_suffix := "_%d"
		var file_path_idx := 0
		while FileAccess.file_exists(file_path + file_path_suffix % file_path_idx + ".tres"):
			file_path_idx += 1
		file_path = file_path + file_path_suffix % file_path_idx
	
	# (Ensure that the user level directory exists before attempting to save.)
	DirAccess.make_dir_recursive_absolute(LEVEL_SAVES_DIRECTORY)
	ResourceSaver.save(saved_level, file_path + ".tres")
