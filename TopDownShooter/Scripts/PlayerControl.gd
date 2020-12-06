extends KinematicBody2D
 
const MOVE_SPEED = 500
var state = "idle"
var health = 10
var facing_right = true
var equipped = false
signal on_health_drop(curHealth)

func _physics_process(delta):
	var dir = get_angle_to(get_global_mouse_position())
	if abs(dir) < 5:
		rotation += dir
	else:
		if dir>0: rotation += 5 #clockwise
		if dir<0: rotation -= 5 #anit - clockwise
	for i in get_slide_count():
		var collision = get_slide_collision(i)
	var move_dirX = 0
	var move_dirY = 0
	if Input.is_action_pressed("move_right"):
		move_dirX += 1
	if Input.is_action_pressed("move_left"):
		move_dirX -= 1
	if Input.is_action_pressed("move_up"):
		move_dirY -= 1
	if Input.is_action_pressed("move_down"):
		move_dirY += 1
	if Input.is_action_just_pressed("equip_weapon"):
		var areas = $WeaponFind.get_overlapping_areas()
		for a in areas:
			if a.get_parent().has_method("equip"):
				a.get_parent().equip(self)
				equip()
				break
	move_and_slide(Vector2(move_dirX * MOVE_SPEED,move_dirY * MOVE_SPEED), Vector2(0,0))

func unequip():
	$WeaponFind/CollisionShape2D.disabled = false
	equipped = false
func equip():
	$WeaponFind/CollisionShape2D.disabled = true
	equipped = true
func WeaponPlace():
	return $WeaponPlace.global_position
func WeaponRotation():
	return $WeaponPlace.global_rotation
func get_hit(damage):
	health -= damage
	emit_signal("on_health_drop",health)
	if(health <= 0):
		get_tree().reload_current_scene()
