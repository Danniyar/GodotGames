extends KinematicBody2D

var right = false
var MOVE_SPEED = 1000
var damage = 100

func _physics_process(delta):
	var end = false
	for collision in get_slide_count():
		var col = get_slide_collision(collision).collider
		if !col.has_meta("player"):
			end = true
		if col.has_meta("enemy"):
			col.hit(damage)
	if end:
		queue_free()
	var move_dir = 0
	if right:
		move_dir += 1
	else:
		move_dir -= 1
	move_and_slide(Vector2(move_dir * MOVE_SPEED, 0), Vector2(0, -1))
