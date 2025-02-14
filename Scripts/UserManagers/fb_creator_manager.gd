class_name FB_CreatorManager extends Node3D


@onready var _user := get_parent().get_node("XROrigin3D") as XROrigin3D

@onready var _creator_menu_holder := $CreatorMenuHolder
@onready var _creator_menu_viewport_in_3D := $CreatorMenuHolder/CreatorMenuViewportIn3D
@onready var _creator_menu_content := _creator_menu_viewport_in_3D.get_scene_instance() as FB_CreatorMenuContent

@onready var _pointer := _user.get_node("RightHand/FunctionPointer") as XRToolsFunctionPointer
@onready var _pointer_raycast := _user.get_node("RightHand/FunctionPointer/RayCast") as RayCast3D

var _placement_object: FB_AssetBase = null
var _placement_zone: FB_Zone = null


func _ready() -> void:
	if not _user == null:
		# Connect to signals from the controllers.
		_user.get_node("LeftHand").button_pressed.connect(_on_left_hand_button_pressed)
		_user.get_node("RightHand").button_pressed.connect(_on_right_hand_button_pressed)
	
	if not _creator_menu_content == null:
		# By default, hide the creator menu.
		_creator_menu_content.set_menu_visibility(false)
		_creator_menu_viewport_in_3D.enabled = false
		
		# Connect to signals from the creator menu.
		_creator_menu_content.object_selected.connect(_begin_placing_object)
		_creator_menu_content.zone_selected.connect(_begin_placing_zone)
		_creator_menu_content.quit_to_main_menu.connect(_quit_to_main_menu)
		
		# Set default tooltip.
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _process(delta: float) -> void:
	if not _user == null:
		# Position the creator menu in front of the user.
		_creator_menu_holder.position = _user.position - Plane.PLANE_XZ.project(_user.basis.z) * 1.25 + Vector3.UP
		_creator_menu_holder.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))
	
	if not _placement_object == null:
		_update_placing_object()
	elif not _placement_zone == null:
		_update_placing_zone()


func _on_left_hand_button_pressed(name: String) -> void:
	# Toggle visibility of the creator menu.
	# (Cannot enter the menu while placing an object or a zone.)
	if name == "ax_button":
		if not _creator_menu_content == null and _placement_object == null and _placement_zone == null:
			var is_visible = _creator_menu_viewport_in_3D.enabled
			_creator_menu_content.set_menu_visibility(not is_visible)
			_creator_menu_viewport_in_3D.enabled = not is_visible


func _on_right_hand_button_pressed(name: String) -> void:
	# Finalize placement of the current object.
	if name == "trigger_click":
		if _placement_object:
			_try_placing_object()
		elif _placement_zone:
			_try_placing_zone_marker()
	
	if name == "grip_click":
		if _placement_zone:
			_try_placing_zone()
	
	# Cancel the placement of the current object or zone.
	if name == "by_button":
		if _placement_object:
			_placement_object.queue_free()
			_placement_object = null
			_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)
		elif _placement_zone:
			_placement_zone.queue_free()
			_placement_zone = null
			_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _begin_placing_object(object_file_path: String) -> void:
	# Hide the menu & add object placement tooltip.
	_creator_menu_content.set_menu_visibility(false)
	_creator_menu_viewport_in_3D.enabled = false
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.OBJECT_PLACEMENT_TOOLTIP)
	
	# Initialize the object.
	_placement_object = load(object_file_path).instantiate()
	
	if not _placement_object:
		push_error("Failed to load object! (Does the asset inherit from FB_AssetBase?)")
		return
	
	# Place the object into the world.
	_placement_object.enter_placement_mode()
	_placement_object.visible = false
	add_child(_placement_object)


func _update_placing_object() -> void:
	if _pointer_raycast.is_colliding() and not _pointer.last_collided_at == null:
		_placement_object.visible = true
		
		var collision_normal := _pointer_raycast.get_collision_normal().normalized()
		var collision_point := _pointer.last_collided_at
		
		_placement_object.position = collision_point + collision_normal * 0.1
		_placement_object.basis = Basis.looking_at(-1 * Plane.PLANE_XZ.project(_user.basis.z))
	
	else:
		_placement_object.visible = false


func _try_placing_object() -> void:
	if _placement_object and _placement_object.visible:
		_placement_object.exit_placement_mode()
		_placement_object = null
		
		# Set default tooltip.
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _begin_placing_zone(zone_index: int) -> void:
	# Hide the menu & add zone placement tooltip.
	_creator_menu_content.set_menu_visibility(false)
	_creator_menu_viewport_in_3D.enabled = false
	_creator_menu_content.set_tooltip(FB_CreatorMenuContent.ZONE_PLACEMENT_TOOLTIP)
	
	# Add the placement zone and the first marker.
	_placement_zone = FB_Zone.new()
	var initial_zone_marker := FB_CreatorManager.make_zone_marker(
		FB_CreatorMenuContent.ZONE_INDEX_TO_COLOR[zone_index])
	initial_zone_marker.visible = false
	_placement_zone.add_child(initial_zone_marker)
	add_child(_placement_zone)


func _update_placing_zone() -> void:
	var cur_zone_marker = _placement_zone.get_child(_placement_zone.get_child_count() - 1)
	
	if _pointer_raycast.is_colliding() and not _pointer.last_collided_at == null:
		cur_zone_marker.visible = true
		cur_zone_marker.position = _pointer.last_collided_at
	
	else:
		cur_zone_marker.visible = false


func _try_placing_zone_marker() -> void:
	if _placement_zone:
		var cur_zone_marker = _placement_zone.get_child(_placement_zone.get_child_count() - 1)
		var zone_is_okay := _placement_zone.get_child_count() < 3 or _placement_zone.check_zone()
		
		if cur_zone_marker.visible and zone_is_okay:
			var next_zone_marker := FB_CreatorManager.make_zone_marker(
				cur_zone_marker.mesh.material.albedo_color)
			next_zone_marker.visible = false
			_placement_zone.add_child(next_zone_marker)


func _try_placing_zone() -> void:
	if _placement_zone:
		var doomed_zone_marker = _placement_zone.get_child(_placement_zone.get_child_count() - 1)
		doomed_zone_marker.queue_free()
		
		var zone_is_valid := _placement_zone.check_zone()
		if not zone_is_valid:
			_placement_zone.queue_free()
		_placement_zone = null
		
		# Set default tooltip.
		_creator_menu_content.set_tooltip(FB_CreatorMenuContent.DEFAULT_TOOLTIP)


func _quit_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://Scenes/Levels/fb_main_menu.tscn")


static func align_with_normal(xform: Transform3D, normal: Vector3) -> Transform3D:
	xform.basis.y = normal.normalized()
	xform.basis.x = -xform.basis.z.cross(xform.basis.y).normalized()
	xform.basis = xform.basis.orthonormalized()
	return xform


static func make_zone_marker(zone_color: Color) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.mesh = SphereMesh.new()
	mesh_instance.mesh.radius = 0.05
	mesh_instance.mesh.height = 0.1
	mesh_instance.mesh.material = StandardMaterial3D.new()
	mesh_instance.mesh.material.albedo_color = zone_color
	mesh_instance.mesh.material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	return mesh_instance
