class_name FB_AssetInteract extends FB_AssetBase

@export var interaction_area: Area3D
@export var animation_interaction: bool
@export var animation_player: AnimationPlayer
@export var animation_name: String
@export var animated_mesh: MeshInstance3D

# This will prevent jittery interactions that add more than one step to recording
@onready var _allow_step: bool = true
@onready var step_timer: Timer = Timer.new()

func _ready() -> void:
	super()
	interaction_area.body_entered.connect(_on_body_entered_interaction_area)
	interaction_area.body_exited.connect(_on_body_exited_interaction_area)
	add_child(step_timer)
	step_timer.one_shot = true
	step_timer.wait_time = 1.0
	step_timer.timeout.connect(_on_step_timer_timeout)

func _process(delta: float) -> void:
	super(delta)
	if (pickable_object.freeze):
		pickable_object.freeze = true

func _on_body_entered_interaction_area(_body: Node3D) -> void:
	if (animation_interaction):
		animated_mesh.get_surface_override_material(0).set_emission_energy_multiplier(4.0)
		animation_player.play(animation_name)
	var object_name = asset_file_path.split('fb_')[1].split(".")[0].capitalize()
	if _allow_step:
		var step := FB_Step.new(
			object_ID, -1, FB_Globals.StepType.OBJECT_INTERACT,
			"  -  [color=orangered]Player[/color] interacts with [color=lightblue]%s[/color] (%d)" % [object_name, object_ID]
		)
		if get_tree().get_first_node_in_group("FB_CreatorManager_Group") != null:
			get_tree().get_first_node_in_group("FB_CreatorManager_Group").try_recording_step(step)
		else:
			get_tree().get_first_node_in_group("FB_PlayerManager_Group").try_completing_step(step)
		
		_allow_step = false
		step_timer.start()

func _on_body_exited_interaction_area(_body: Node3D) -> void:
	if (animation_interaction):
		animated_mesh.get_surface_override_material(0).set_emission_energy_multiplier(1.0)
		animation_player.play_backwards(animation_name)

func _on_step_timer_timeout() -> void:
	_allow_step = true
