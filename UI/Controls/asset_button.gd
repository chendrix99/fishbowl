extends Button

signal asset_button_pressed(asset_file: String)

var asset_file_name: String = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_asset_button_pressed)

func _on_asset_button_pressed() -> void:
	asset_button_pressed.emit(self.asset_file_name)
