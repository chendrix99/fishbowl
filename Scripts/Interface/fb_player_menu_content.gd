class_name FB_PlayerMenuContent extends Control

signal quit_to_main_menu
signal restart_level

@onready var _tooltip := $Tooltip
@onready var _tooltip_label := $Tooltip/TooltipLabel
@onready var _player_menu := $PlayerMenu
@onready var _level_description := $PlayerMenu/TabContainer/Level/VBoxContainer/LevelDescription
@onready var _level_title := $PlayerMenu/TabContainer/Level/VBoxContainer/LevelTitle

const DEFAULT_TOOLTIP = "  (Press X to show/hide the menu.)  "

func _ready() -> void:
	pass
	
func set_menu_visibility(is_visible: bool) -> void:
	_tooltip.visible = not is_visible
	_player_menu.visible = is_visible
	
func set_tooltip(tooltip: StringName) -> void:
	_tooltip_label.text = tooltip

func _on_quit_to_main_menu_button_pressed() -> void:
	quit_to_main_menu.emit()
	print("<debug> Quitting to main menu.")

func _on_restart_level_pressed() -> void:
	restart_level.emit()
	print("<debug> Restarting Level.")
