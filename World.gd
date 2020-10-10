extends Spatial


func _on_Daytime_timeout():
	print("tick")
	$DirectionalLight.global_transform.origin.y += 1
