extends Control

var button_text: String = "": set = set_button_text

var button_icon: Texture2D = null: set = set_button_icon

func set_button_text(text: String) -> void:
	$AssetButton.text = text

func set_button_icon(icon: Texture2D) -> void:
	$AssetButton.icon = icon

func set_button_callback(callback: Callable):
	$AssetButton.pressed.connect(callback)
