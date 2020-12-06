extends Spatial

func delete():
	queue_free()

func place(hitPoint):
	var distance = 2
	var position = global_transform.origin
	if(int(global_transform.origin.x - hitPoint.x) >= 1):
		position.x -= distance
	elif(int(global_transform.origin.x - hitPoint.x) <= -1):
		position.x += distance
	elif(int(global_transform.origin.y - hitPoint.y) >= 1):
		position.y -= distance
	elif(int(global_transform.origin.y - hitPoint.y) <= -1):
		position.y += distance
	elif(int(global_transform.origin.z - hitPoint.z) >= 1):
		position.z -= distance
	elif(int(global_transform.origin.z - hitPoint.z) <= -1):
		position.z += distance
	get_parent().newBlock(position)
