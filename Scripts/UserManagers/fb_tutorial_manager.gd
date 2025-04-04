class_name FB_TutorialManager extends FB_CreatorManager

@onready var _prompt := $FB_TutorialPrompt

## These hold all of the text used in the tutorial and are just accessed by
## index depending on which step is being done.
@onready var _headers := [
	"Welcome!",
	"Moving Around:",
	"The Creator Menu:",
	"Placing a Zone:",
	"Placing an Object:",
	"Placing an Interactable Object:",
	"Recording Your Experience:",
	"Wrapping up:"
]

@onready var _prompts := [
	"Welcome to Fishbowl: Spatial Experience Designer!\n\nThis short tutorial will walk you through how to create a spatial experience that can be shared with others.\n\nYou will learn the process of creating an experience, types of interactions supported and the controls that are used.\n\nLets get started!",
	"To move around the scene you can either physically move or use the joysticks on the controllers.\n\nThe joystick on the Left controller allows you to move around and the joystick on the Right controller allows you to look around.\n\nPractice moving around the scene and when ready click Continue.",
	"The Creator Menu is where you will add things like Zones and Objects to your experience.\n\nTo open and close the menu press the X button on the left controller (The bottom button). To select things in the menu use the pointer and the trigger on the right controller.\n\nExplore this menu and then click Continue.",
	"The main driver of creating experiences in Fishbowl is defining and interacting with Zones.\n\nZones are highlighted 3D spaces in the scene that are created by you. You create a Zone by defining it's vertices and optionally setting the height.\n\nTry creating a Zone by going into the Creator Menu and the Zones tab. Click on a Zone color and place 4 points with the right trigger, when done press the grip button on the inside of the right controller.\n\nTo adjust the height hover the pointer on the Zone and then press and hold the right trigger, then move the controller up or down.\n\nClick okay to try placing a Zone, when done click Continue.",
	"Objects will make your experience feel more interactive and realistic. Objects are placed very similarly to Zones.\n\nFrom the Creator Menu go to the Objects tab and use the pointer to select the Asset Block Base. After selecting you can move the Block with the pointer anywhere you like, use the right trigger to place the Block.\n\nAfter placing, go up to the Block and use either grip buttons on the controllers to pick it up. Objects will highlight when they can be picked up. Objects and Zones can be deleted with the B button on the right controller (Top Button).\n\nClick Okay to try this out and then click Continue when ready.",
	"There are certain Objects that allow you to interact with them.\n\nGo back into the Creator Menu and try placing the Green Push Button. After placing it you can move up to the button and use your hands in VR to press it.\n\nThis button will react to being pressed and can be recorded in your experience.\n\nTry this out by clicking Okay and when ready click Continue",
	"Now you are ready to record your experience!\nWhile in the Creator Menu go to the Record tab and press Start Recording. A red dot will let you know that recording is in progress.\n\nSpecific actions are recorded in Fishbowl:\n\tMoving Objects into or out of Zones\n\tMoving yourself in or out of Zones\n\tInteracting with Objects like Buttons\n\nBy cleverly ordering these recordable events you can create a multitude of unique experiences. Time to try it out, when finished press the B button on the right controller (Top Button) to end recording then click Continue.",
	"Great Work! You now know how to create experiences in Fishbowl!\n\nThe last step would be to Save your experience for others to play later on. In the Creator Menu click the Save button on the top right and give your experience a name. Then you can exit back to the main menu.\n\nFeel free to keep practicing here. When you are ready clicking the Continue button will take you back to the main menu."
]

@onready var _creator_menu_ready := false
@onready var _recording_ready := false

var _tutorial_step: int

func _ready() -> void:
	super()
	reset_prompt_creator()
	_tutorial_step = 0
	
	_prompt.set_okay_callback(on_welcome_okay_pressed)
	_prompt.set_prompt_text(_prompts[_tutorial_step])
	_prompt.set_header_text(_headers[_tutorial_step])


func _process(delta: float) -> void:
	super(delta)
	_prompt.position = _user.position - Plane.PLANE_XZ.project(_user.basis.z) * 1.25 + Vector3.UP*1.5
	_prompt.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))


func _on_left_hand_button_pressed(button_name: String) -> void:
	if not _creator_menu_ready:
		return
	super(button_name)


func _quit_to_main_menu() -> void:
	pass


func _start_recording() -> void:
	if not _recording_ready:
		return
	_is_recording = true
	recorded_steps = []
	_creator_menu_content.recorded_steps.text = ""
	_creator_menu_content.recorded_steps_icon.visible = true
	
	# Hide the menu & add default tooltip.
	_creator_menu_content.set_menu_visibility(false)
	_creator_menu_viewport_in_3D.enabled = false
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.RECORDING_TOOLTIP)


func _end_recording() -> void:
	_is_recording = false
	_creator_menu_content.recorded_steps_icon.visible = false
	
	# Hide the menu & add default tooltip.
	_creator_menu_content.set_menu_visibility(false)
	_creator_menu_viewport_in_3D.enabled = false
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


#-------------------------------------------------------------------------------
## Callbacks for progressing through the tutorial
func on_welcome_okay_pressed():
	_tutorial_step += 1
	_prompt.disconnect_okay_callback(on_welcome_okay_pressed)
	_prompt.set_okay_callback(on_okay_pressed)
	_prompt.set_prompt_text(_prompts[_tutorial_step])
	_prompt.set_header_text(_headers[_tutorial_step])


func on_okay_pressed():
	if _tutorial_step == 2:
		_creator_menu_ready = true
	if _tutorial_step == 6:
		_recording_ready = true
	_prompt.disable()
	_prompt.disconnect_okay_callback(on_okay_pressed)
	_prompt.set_okay_callback(on_continue_pressed)


func on_continue_pressed():
	_tutorial_step += 1
	if _tutorial_step == 8:
		get_tree().change_scene_to_file("res://Scenes/main.tscn")
		return
	_prompt.enable()
	_prompt.disconnect_okay_callback(on_continue_pressed)
	_prompt.set_okay_callback(on_okay_pressed)
	_prompt.set_prompt_text(_prompts[_tutorial_step])
	_prompt.set_header_text(_headers[_tutorial_step])
#-------------------------------------------------------------------------------
