extends KinematicBody
 
const MOVE_SPEED = 4
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
 
onready var cam = $CamBase
onready var anim = $AnimationPlayer
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var current_animation = "idle"
var queue = 1

var health = 100
var energy = 100
var potions = 3
var energydown = false
var can_hit = true

var can = true
 
func _ready():
	set_meta("player",true)
	$CamBase/CameraCorrector.add_exception(self)
	cam.set_as_toplevel(true)
	$AnimationTree.active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		cam.rotation_degrees.y -= event.relative.x * H_LOOK_SENS
	if event is InputEventJoypadMotion:
		cam.rotation_degrees.x += (Input.get_action_strength("Gamepad_right_right") - Input.get_action_strength("Gamepad_right_left")) * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		cam.rotation_degrees.y += (Input.get_action_strength("Gamepad_right_down") - Input.get_action_strength("Gamepad_right_up")) * H_LOOK_SENS
 
func _physics_process(delta):
	if Input.is_action_just_pressed("restart"):
		die()
	if energy < 100:
		energy += 0.2
	if energy > 25:
		energydown = false
	$CanvasLayer/HPBar.value = health
	$CanvasLayer/EGBar.value = energy
	if $CamBase/CameraCorrector.get_collider() != null:
		$CamBase/Camera.global_transform.origin = $CamBase/CameraCorrector.get_collision_point()
	cam.global_transform.origin = global_transform.origin
	cam.global_transform.origin.y += 0.7
	if global_transform.origin.y <= -15:
		global_transform.origin = Vector3(-3.753,0.502,-8.28)
	if state_machine.get_current_node() == "walk" || state_machine.get_current_node() == "idle" || state_machine.get_current_node() == "run":
		can = true
	else:
		can = false
	
	if Input.is_action_just_pressed("switch"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CONFINED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	var moving = false
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards") && can:
		move_vec.z -= Input.get_action_strength("move_forwards")
		moving = true
		rotation_degrees.y = cam.rotation_degrees.y
	if Input.is_action_pressed("move_backwards") && can:
		move_vec.z += Input.get_action_strength("move_backwards")
		moving = true
		rotation_degrees.y = cam.rotation_degrees.y - 180
	if Input.is_action_pressed("move_right") && can:
		move_vec.x += Input.get_action_strength("move_right")
		moving = true
		rotation_degrees.y = cam.rotation_degrees.y - 90
	if Input.is_action_pressed("move_left") && can:
		move_vec.x -= Input.get_action_strength("move_left")
		moving = true
		rotation_degrees.y = cam.rotation_degrees.y + 90
	
	var running = false
	
	if Input.is_action_pressed("run"):
		running = true
	
	if Input.is_action_just_pressed("heal") && can && potions > 0:
		play_anim("heal")
		return
		
	if moving && running && can && !energydown:
		energy -= 0.4
		play_anim("run")
	elif moving && can:
		play_anim("walk")
	elif can:
		play_anim("idle")
	
	if health <= 0:
		play_anim("death")
	
	if Input.is_action_just_pressed("attack") && can && !energydown:
		energy -= 25
		play_anim("attack")
		return
	elif Input.is_action_just_pressed("hard_attack") && can && !energydown:
		energy -= 50
		if queue > 0:
			play_anim("hard_attack")
		return
	elif Input.is_action_just_pressed("roll") && can && !energydown:
		energy -= 30
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
		roll.track_set_key_value(52,0,Vector3(global_transform.origin.x,global_transform.origin.y - 1.4,global_transform.origin.z))
		play_anim("roll")
		return
	
	if energy <= 0:
		energydown = true
	
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), cam.rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	if running && !energydown:
		move_vec.x *= 2
		move_vec.z *= 2
	move_and_slide(move_vec, Vector3(0, 1, 0))
 
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

func hit(damage):
	health -= damage
	if health > 0:
		play_anim("Hit")
	else:
		play_anim("death")

func die():
	get_tree().reload_current_scene()

func can_be_hit_no():
	can_hit = false

func can_be_hit_yes():
	can_hit = true
	
func _on_sword_body_entered(body):
	if body.has_meta("enemy"):
		if state_machine.get_current_node() == "attack":
			body.hit(40)
		elif state_machine.get_current_node() == "hard_attack":
			body.hit(80)
	pass # Replace with function body.

func heal():
	potions -= 1
	$CanvasLayer/Estus.text = str(potions)
	health += 40
	if health > 100:
		health = 100
