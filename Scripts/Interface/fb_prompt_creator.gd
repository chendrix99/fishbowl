class_name FB_PromptCreator extends Node3D

# This is a class to facilitate user created text prompts throughout the
# recording process.

# Signal for when the user presses the done or cancel button
signal user_pressed_done_cancel(prompt_text: String)

@onready var prompt_content := $FB_PromptDisplay.get_scene_instance() as Control
@onready var prompt := prompt_content.get_child(1) as TextEdit
@onready var header := prompt_content.get_child(3) as RichTextLabel

@onready var done_cancel_content := $DoneCancel.get_scene_instance() as Control
@onready var cancel_button := done_cancel_content.get_child(1).get_child(0) as Button
@onready var done_button := done_cancel_content.get_child(1).get_child(1) as Button

func _ready() -> void:
	prompt.set_caret_blink_enabled(true)
	cancel_button.pressed.connect(_on_cancel_button_pressed)
	done_button.pressed.connect(_on_done_button_pressed)

func _unhandled_key_input(event: InputEvent) -> void:
	if (event.physical_keycode != KEY_UNKNOWN):
		if (event.physical_keycode == KEY_BACKSPACE):
			prompt.backspace()
		elif (event.physical_keycode == KEY_ENTER):
			prompt.insert_text_at_caret("\n")
		elif (event.shift_pressed):
			prompt.insert_text_at_caret(String.chr(event.unicode))
		else:
			prompt.insert_text_at_caret(String.chr(event.unicode).to_lower())

func _on_cancel_button_pressed():
	user_pressed_done_cancel.emit("")

func _on_done_button_pressed():
	user_pressed_done_cancel.emit(prompt.text)

func set_header_text(text: String):
	header.text = text
