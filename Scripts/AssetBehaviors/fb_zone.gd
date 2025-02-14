class_name FB_Zone extends MeshInstance3D


var _is_valid := false


func _process(_delta: float) -> void:
	_update_zone()


func check_zone() -> bool:
	_update_zone()
	return _is_valid


func _update_zone() -> void:
	# Reset the mesh and zone validity.
	_is_valid = false
	mesh = null
	
	# Zones must have a minimum of three points.
	if get_child_count() < 3:
		return
	
	var zone_points := PackedVector2Array()
	for zone_marker in get_children():
		zone_points.push_back(Vector2(zone_marker.position.x, zone_marker.position.z))
	
	# Check if the triangulation failed.
	var triangle_indices := Geometry2D.triangulate_polygon(zone_points)
	if triangle_indices.is_empty():
		return
	
	var vertex_positions := PackedVector3Array()
	var vertex_normals := PackedVector3Array()
	for i in range(0, triangle_indices.size(), 3):
		var v0 = get_child(triangle_indices[i]).position + Vector3.UP * 0.2
		var v1 = get_child(triangle_indices[i + 1]).position + Vector3.UP * 0.2
		var v2 = get_child(triangle_indices[i + 2]).position + Vector3.UP * 0.2
		
		vertex_positions.append_array([ v0, v1, v2 ])
		vertex_normals.append_array([ Vector3.UP, Vector3.UP, Vector3.UP ])
	
	var mesh_arrays := Array()
	mesh_arrays.resize(Mesh.ARRAY_MAX)
	mesh_arrays[Mesh.ARRAY_VERTEX] = vertex_positions
	mesh_arrays[Mesh.ARRAY_NORMAL] = vertex_normals
	
	mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_arrays)
	mesh.surface_set_material(0, StandardMaterial3D.new())
	
	_is_valid = true
