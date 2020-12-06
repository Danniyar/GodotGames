extends Particles2D


var time = 1

func _physics_process(delta):
	if time > 0:
		time -= delta
		if time <= 0:
			queue_free()
