extends Camera
 
func _physics_process(delta):
	get_tree().call_group("portals", "update_cam", global_transform)
