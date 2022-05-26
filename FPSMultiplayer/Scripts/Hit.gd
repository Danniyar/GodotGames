extends Particles

var time = 0.15

func _physics_process(delta):
	time -= delta
	if(time <= 0):
		queue_free()
		rpc("queue_free_all")
	else:
		rpc_unreliable("update_position",global_transform)

remote func update_position(pos):
	global_transform = pos

remote func queue_free_all():
	queue_free()
