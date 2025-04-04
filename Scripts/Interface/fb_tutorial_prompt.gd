class_name FB_TutorialPrompt extends Node3D

@onready var prompt_content := $FB_PromptDisplay.get_scene_instance() as Control
@onready var prompt := prompt_content.get_child(1) as TextEdit
@onready var header := prompt_content.get_child(3) as RichTextLabel

@onready var okay_button := $Okay.get_scene_instance().get_child(0) as Button

func _ready() -> void:
	prompt.selecting_enabled = false
	header.selection_enabled = false


func set_header_text(text: String):
	header.text = text


func set_prompt_text(text: String):
	prompt.text = text


func set_okay_callback(callback: Callable):
	okay_button.pressed.connect(callback)


func disconnect_okay_callback(callback: Callable):
	okay_button.pressed.disconnect(callback)


func disable():
	$FB_PromptDisplay.enabled = false
	$FB_PromptDisplay.visible = false
	okay_button.text = "Continue"


func enable():
	$FB_PromptDisplay.enabled = true
	$FB_PromptDisplay.visible = true
	okay_button.text = "Okay"
