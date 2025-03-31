class_name FB_MainMenuContent extends Control

# This node will be instantiated by a "Viewport 2D in 3D" node.
# This script should contain internal logic for the UI and expose certain
# buttons/signals that can be connected to from the owning 3D scene.

const LEVEL_BUTTON := preload("res://Scenes/Interface/fb_main_menu_level_button.tscn")

@onready var main_menu := $MainMenu
@onready var create_menu := $CreateMenu
@onready var create_level_menu := $CreateLevelMenu
@onready var create_level_section := $CreateLevelMenu/LevelSection/VBoxContainer
@onready var edit_level_menu := $EditLevelMenu
@onready var edit_level_section := $EditLevelMenu/LevelSection/VBoxContainer
@onready var play_level_menu := $PlayLevelMenu
@onready var play_level_section := $PlayLevelMenu/LevelSection/VBoxContainer



func _ready() -> void:
	main_menu.visible = true
	create_menu.visible = false
	create_level_menu.visible = false
	edit_level_menu.visible = false
	play_level_menu.visible = false


func _on_create_level_button_pressed():
	main_menu.visible = false
	create_menu.visible = false
	create_level_menu.visible = true
	edit_level_menu.visible = false
	play_level_menu.visible = false
	
	for doomed_child in create_level_section.get_children():
		doomed_child.queue_free()
	
	for level_template_file_name in DirAccess.get_files_at(FB_LevelManager.LEVEL_TEMPLATE_DIRECTORY):
		var level_button := LEVEL_BUTTON.instantiate() as Button
		level_button.text = level_template_file_name.trim_prefix("fb_").trim_suffix(".remap").trim_suffix(".tscn").capitalize()
		level_button.pressed.connect(
			FB_LevelManagerInstance.create_level.bind(FB_LevelManager.LEVEL_TEMPLATE_DIRECTORY + level_template_file_name.trim_suffix(".remap")))
		create_level_section.add_child(level_button)


func _on_edit_level_button_pressed():
	main_menu.visible = false
	create_menu.visible = false
	create_level_menu.visible = false
	edit_level_menu.visible = true
	play_level_menu.visible = false
	
	for doomed_child in edit_level_section.get_children():
		doomed_child.queue_free()
	
	# (Ensure that the user level directory exists before opening.)
	DirAccess.make_dir_recursive_absolute(FB_LevelManager.LEVEL_SAVES_DIRECTORY)
	
	for level_file_name in DirAccess.get_files_at(FB_LevelManager.LEVEL_SAVES_DIRECTORY):
		var level_button := LEVEL_BUTTON.instantiate() as Button
		level_button.text = level_file_name.trim_prefix("fb_").trim_suffix(".tres").capitalize()
		level_button.pressed.connect(
			FB_LevelManagerInstance.edit_level.bind(FB_LevelManager.LEVEL_SAVES_DIRECTORY + level_file_name))
		edit_level_section.add_child(level_button)


func _on_play_level_button_pressed():
	main_menu.visible = false
	create_menu.visible = false
	create_level_menu.visible = false
	edit_level_menu.visible = false
	play_level_menu.visible = true
	
	for doomed_child in play_level_section.get_children():
		doomed_child.queue_free()
	
	# (Ensure that the user level directory exists before opening.)
	DirAccess.make_dir_recursive_absolute(FB_LevelManager.LEVEL_SAVES_DIRECTORY)
	
	for level_file_name in DirAccess.get_files_at(FB_LevelManager.LEVEL_SAVES_DIRECTORY):
		var level_button := LEVEL_BUTTON.instantiate() as Button
		level_button.text = level_file_name.trim_prefix("fb_").trim_suffix(".tres").capitalize()
		level_button.pressed.connect(
			FB_LevelManagerInstance.play_level.bind(FB_LevelManager.LEVEL_SAVES_DIRECTORY + level_file_name))
		play_level_section.add_child(level_button)


func _on_quit_button_pressed():
	get_tree().quit()


func _on_back_button_pressed():
	if(edit_level_menu.visible == true or create_level_menu.visible == true):
		main_menu.visible = false
		create_menu.visible = true
		edit_level_menu.visible = false
		create_level_menu.visible = false
		play_level_menu.visible = false
	else:
		main_menu.visible = true
		create_menu.visible = false
		create_level_menu.visible = false
		edit_level_menu.visible = false
		play_level_menu.visible = false
		
func _on_create_menu_button_pressed():
	main_menu.visible = false
	create_menu.visible = true
	create_level_menu.visible = false
	edit_level_menu.visible = false
	play_level_menu.visible = false
