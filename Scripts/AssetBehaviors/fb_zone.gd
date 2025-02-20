@tool class_name FB_Zone extends MeshInstance3D

signal zone_entered_or_exited(step)

var zone_height := 0.25
var zone_id: int
var _zone_vertices := PackedVector2Array()
var _zone_y_level := 0.00
var _zone_is_committed := false
var _zone_color := Color.WHITE
# Using an Area3D here now so that objects entering/exiting are tracked
var _area_3d: Area3D = null
var _zone_material := StandardMaterial3D.new()


func _init(zone_color: Color) -> void:
	_zone_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA_DEPTH_PRE_PASS
	_zone_material.albedo_color = zone_color
	_zone_material.albedo_color.a = 0.4
	_zone_material.diffuse_mode = BaseMaterial3D.DIFFUSE_TOON
	_zone_material.specular_mode = BaseMaterial3D.SPECULAR_TOON
	_zone_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Increment the zone id and use that as this zones id
	FB_Globals.ZONE_ID += 1
	zone_id = FB_Globals.ZONE_ID


func _process(_delta: float) -> void:
	if not _zone_is_committed:
		update_zone(false)


func check_zone() -> bool:
	if not _zone_is_committed:
		update_zone(false)
	return mesh != null


func commit_zone() -> void:
	# (Get rid of placeholder meshes for the vertex markers.)
	for child in get_children():
		if child is MeshInstance3D:
			child.mesh = null
	
	update_zone(true)
	if mesh == null:
		push_error("Committed an invalid zone!")
	
	_zone_is_committed = true


func update_zone(refresh_collider: bool) -> void:
	mesh = null
	
	var got_y_level := false
	
	_zone_vertices.clear()
	for zone_child in get_children():
		if zone_child is not Area3D:
			if not got_y_level:
				_zone_y_level = zone_child.position.y
				got_y_level = true
			
			_zone_vertices.push_back(Vector2(zone_child.position.x, zone_child.position.z))
	
	if _zone_vertices.size() < 3:
		return
	
	var is_clockwise := Geometry2D.is_polygon_clockwise(_zone_vertices)
	if is_clockwise:
		_zone_vertices.reverse()
	
	var triangle_vertex_indices := Geometry2D.triangulate_polygon(_zone_vertices)
	if triangle_vertex_indices.is_empty():
		return
	
	var vertex_positions := PackedVector3Array()
	var vertex_normals := PackedVector3Array()
	
	# Add bottom and top faces.
	for i in range(0, triangle_vertex_indices.size(), 3):
		var v0 = _zone_vertices[triangle_vertex_indices[i]]
		var v1 = _zone_vertices[triangle_vertex_indices[i + 1]]
		var v2 = _zone_vertices[triangle_vertex_indices[i + 2]]
		
		var v0_bottom = Vector3(v0.x, _zone_y_level, v0.y)
		var v1_bottom = Vector3(v1.x, _zone_y_level, v1.y)
		var v2_bottom = Vector3(v2.x, _zone_y_level, v2.y)
		
		var v0_top = Vector3(v0.x, _zone_y_level + zone_height, v0.y)
		var v1_top = Vector3(v1.x, _zone_y_level + zone_height, v1.y)
		var v2_top = Vector3(v2.x, _zone_y_level + zone_height, v2.y)
		
		vertex_positions.append_array([ v0_bottom, v2_bottom, v1_bottom ])
		vertex_normals.append_array([ Vector3.DOWN, Vector3.DOWN, Vector3.DOWN ])
		
		vertex_positions.append_array([ v0_top, v1_top, v2_top ])
		vertex_normals.append_array([ Vector3.UP, Vector3.UP, Vector3.UP ])
	
	# Add side faces.
	for cur_i in _zone_vertices.size():
		var next_i = cur_i + 1
		if next_i == _zone_vertices.size():
			next_i = 0
		
		var a = Vector3(_zone_vertices[cur_i].x, _zone_y_level + zone_height, _zone_vertices[cur_i].y)
		var b = Vector3(_zone_vertices[next_i].x, _zone_y_level + zone_height, _zone_vertices[next_i].y)
		var c = Vector3(_zone_vertices[next_i].x, _zone_y_level, _zone_vertices[next_i].y)
		var d = Vector3(_zone_vertices[cur_i].x, _zone_y_level, _zone_vertices[cur_i].y)
		
		var n1 := ((b - c).cross(a - c)).normalized()
		var n2 := ((a - c).cross(d - c)).normalized()
		
		vertex_positions.append_array([ c, b, a ])
		vertex_normals.append_array([ n1, n1, n1 ])
		
		vertex_positions.append_array([ c, a, d ])
		vertex_normals.append_array([ n2, n2, n2 ])
	
	var mesh_arrays := Array()
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertex_positions
	mesh_arrays[Mesh.ARRAY_NORMAL] = vertex_normals
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	mesh.surface_set_material(0, _zone_material)
	
	if refresh_collider and mesh:
		if not _area_3d:
			_area_3d = Area3D.new()
			# Track pickable objects and player body
			_area_3d.collision_mask = 0x80004
			_area_3d.body_entered.connect(_on_body_entered_zone)
			_area_3d.body_exited.connect(_on_body_exited_zone)
			add_child(_area_3d)
		
		for doomed_collision_shape in _area_3d.get_children():
			doomed_collision_shape.queue_free()
		
		var shape_from_mesh = mesh.create_convex_shape(true)
		var collision_shape := CollisionShape3D.new()
		collision_shape.shape = shape_from_mesh
		_area_3d.add_child(collision_shape) 

# Handle an object/body entering this zone
func _on_body_entered_zone(body: Node3D):
	var object_id: int
	if (body is XRToolsPlayerBody):
		object_id = 1
	elif (body is FB_AssetBase):
		object_id = body.object_id
	zone_entered_or_exited.emit(
		FB_Step.new(object_id, zone_id, FB_Globals.StepType.ZONE_ENTERED)
	)

# Handle an object/body exiting this zone
func _on_body_exited_zone(body: Node3D):
	var object_id: int
	if (body is XRToolsPlayerBody):
		object_id = 1
	elif (body is FB_AssetBase):
		object_id = body.object_id
	zone_entered_or_exited.emit(
		FB_Step.new(object_id, zone_id, FB_Globals.StepType.ZONE_EXITED)
	)
