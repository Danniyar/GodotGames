extends KinematicBody
 
const MOVE_SPEED = 4
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30

onready var anim = $AnimationPlayer
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var current_animation = "idle"
var queue = 1

var health = 100
var energydown = false
var target = null

var can = true
 
func _ready():
	set_meta("enemy",true)
	$AnimationTree.active = true
	pass
 
func _physics_process(delta):
	if global_transform.origin.y <= -15:
		global_transform.origin = Vector3(-3.753,0.502,-8.28)
	if state_machine.get_current_node() == "walk" || state_machine.get_current_node() == "idle" || state_machine.get_current_node() == "run":
		can = true
	else:
		can = false
	
	if state_machine.get_current_node() == "Hit" || state_machine.get_current_node() == "death":
		can = false
		
	var moving = true
	
	var running = false
	var distance = null
	
	if target != null:
		distance = sqrt(pow((target.global_transform.origin.x - global_transform.origin.x),2) + pow((target.global_transform.origin.z - global_transform.origin.z),2))
	
	if target != null && distance >= 5:
		running = true
	
	var move_vec = Vector3(0,0,0)
	
	if target != null && can:
		move_vec.z -= 1
		look_at(target.global_transform.origin, Vector3(0,1,0))
		
	if moving && running && can && !energydown:
		play_anim("run")
	elif moving && can:
		play_anim("walk")
	elif can:
		play_anim("idle")
	
	if target != null && can && distance <= 1.4:
		if queue > 0:
			play_anim("attack")
		else:
			play_anim("attack2")
		queue = -queue
		return
		
	elif 1 == 2 && can && !energydown:
		var roll = anim.get_animation("roll")
		var change
		if $ObstacleFinder.get_collider() != null:
			if abs(int(round(rotation_degrees.y / 90) * 90) % 180) == 0:
				change = Vector3(0,-1.4, -abs($ObstacleFinder.get_collision_point().z - global_transform.origin.z))
			else:
				change = Vector3(0,-1.4, -abs($ObstacleFinder.get_collision_point().x - global_transform.origin.x))
		else:
			change = Vector3(0,global_transform.origin.y - 0.7,-3)
		change = change.rotated(Vector3(0,1,0),rotation.y)
		roll.track_set_key_value(52,1,global_transform.origin + change)
		roll.track_set_key_value(52,0,Vector3(global_transform.origin.x, global_transform.origin.y - 1.4,global_transform.origin.z))
		play_anim("roll")
		return
		
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation_degrees.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	if running && can:
		move_vec.z *= 1.75
		move_vec.x *= 1.75
		
	move_and_slide(move_vec, Vector3(0,1,0))
 
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_just_pressed("jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED

func play_anim(name):
	if state_machine.get_current_node() == name:
		return
	state_machine.travel(name)


func _on_TargetFinder_body_entered(body):
	if body.has_meta("player"):
		target = body
	pass # Replace with function body.


func _on_TargetFinder_body_exited(body):
	if body.has_meta("player"):
		target = null
	pass # Replace with function body.

func hit(damage):
	health -= damage
	if health > 0:
		play_anim("Hit")
	else:
		play_anim("death")

func die():
	queue_free()

func _on_sword_body_entered(body):
	if body.has_meta("player") && body.can_hit:
		body.hit(20)
	pass # Replace with function body.
