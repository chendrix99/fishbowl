@tool
extends XRToolsSceneBase

@onready var wrist_menu: Node3D = $FBWristMenu

func hide_wrist_menu(name: String) -> bool:
	if name == "ax_button":
		if wrist_menu.is_shown:
			remove_child(wrist_menu)
			wrist_menu.set_is_shown(false)
		else:
			add_child(wrist_menu)
			wrist_menu.set_is_shown(true)
	return true
