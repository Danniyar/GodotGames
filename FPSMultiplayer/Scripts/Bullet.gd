extends KinematicBody

var damage = 1
var speed = 1
const HIT = preload("res://prefabs/Hit.tscn")
var time = 10

func _physics_process(delta):
	time -= delta
	if(time <= 0):
		queue_free()
		rpc("queue_free_all")
	else:
		rpc_unreliable("update_position",global_transform)
		
	for col in get_slide_count():
		var collision = get_slide_collision(col)
		if(collision != null && collision.has_meta("player")):
			if(collision.health - damage <= 0):
				get_parent().get_parent().get_parent().kills += 1
			collision.get_hit(damage)
			collision.rpc("get_hit",damage)
		if collision != null:
			var hit = HIT.instance()
			hit.global_transform.origin = global_transform.origin
			get_parent().add_child(hit)
			hit.emitting = true
			hit.global_scale(Vector3(0.1,0.1,0.1))
			rpc("spawn_hit",hit.global_transform.origin,hit.scale,true)
			queue_free()
			rpc("queue_free_all")
	var move_vec = Vector3()
	move_vec.z += -1
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= speed
	move_and_slide(move_vec, Vector3(0, 1, 0))

remote func update_position(pos):
	global_transform = pos

remote func queue_free_all():
	queue_free()

remote func spawn_hit(position,Scale,emitting):
	var hit = HIT.instance()
	hit.global_transform.origin = position
	hit.emitting = emitting
	hit.global_scale(Scale)
	get_parent().add_child(hit)
