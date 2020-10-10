extends Camera

var hidden_objects = []
var latest_collision = []

func _process(delta):
	for i in range(latest_collision.size()-1):
		latest_collision[i] -= 1
		if latest_collision[i] < 0:
			showMesh(hidden_objects[i], i)
	if $CameraRaycast.is_colliding():
		var obj = $CameraRaycast.get_collider()
		var parent = obj.get_parent()
		var index = hidden_objects.find(parent)
		if index > -1: 
			if latest_collision[index] < 100:
				latest_collision[index] += 1;
			return
		elif parent is MeshInstance:
			hideMesh(parent)

func hideMesh(mesh: MeshInstance):
	hidden_objects.append(mesh)
	latest_collision.append(1)
	var mat = SpatialMaterial.new()
	mat.flags_transparent = true
	mat.albedo_color = Color(1,1,1,0.2)
	mesh.material_override = mat

func showMesh(mesh: MeshInstance, index: int):
	mesh.material_override = null
	latest_collision.remove(index)
	hidden_objects.remove(index)
	
