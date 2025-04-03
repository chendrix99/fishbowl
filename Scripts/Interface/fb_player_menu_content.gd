class_name FB_PlayerMenuContent extends Control

@onready var name_label := $PlaybackMenu/MarginContainer/VBoxContainer/HBoxContainer/NameLabel
@onready var description_label := $PlaybackMenu/MarginContainer/VBoxContainer/OtherDetails/DescriptionLabel
@onready var steps_label := $PlaybackMenu/MarginContainer/VBoxContainer/OtherDetails/StepsLabel


func _on_restart_button_pressed():
	FB_LevelManagerInstance.play_level_directly(FB_LevelManagerInstance._loaded_level)


func _on_quit_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/main.tscn")


func _on_compress_button_pressed():
	$PlaybackMenu/MarginContainer/VBoxContainer/OtherDetails.visible = \
		not $PlaybackMenu/MarginContainer/VBoxContainer/OtherDetails.visible
