extends RayCast

func _physics_process(delta):
	var collision = get_collider()
	if(collision != null):
		if(collision.get_meta("enemy")):
			get_parent().target = collision
