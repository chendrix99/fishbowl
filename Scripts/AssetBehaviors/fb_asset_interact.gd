class_name FB_AssetInteract extends FB_AssetBase

signal object_interacted_with(step)

@export var interaction_area: Area3D

@export var animation_interaction: bool
@export var animation_player: AnimationPlayer
@export var animation_name: String
@export var animated_mesh: MeshInstance3D

func _ready() -> void:
	super()
	interaction_area.body_entered.connect(_on_body_entered_interaction_area)
	interaction_area.body_exited.connect(_on_body_exited_interaction_area)

func _process(delta: float) -> void:
	super(delta)
	if (pickable_object.freeze):
		pickable_object.freeze = true

func _on_body_entered_interaction_area(_body: Node3D) -> void:
	if (animation_interaction):
		animated_mesh.get_surface_override_material(0).set_emission_energy_multiplier(4.0)
		animation_player.play(animation_name)
	object_interacted_with.emit(
		FB_Step.new(object_id, -1, FB_Globals.StepType.OBJECT_INTERACT)
	)

func _on_body_exited_interaction_area(_body: Node3D) -> void:
	if (animation_interaction):
		animated_mesh.get_surface_override_material(0).set_emission_energy_multiplier(1.0)
		animation_player.play_backwards(animation_name)
