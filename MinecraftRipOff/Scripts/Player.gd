extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 15
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 0.5
const V_LOOK_SENS = 0.5
 
onready var cam = $Camera
onready var ray = $Camera/RayCast
 
var y_velo = 0
 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	if(global_transform.origin.y <= -15):
		global_transform.origin.y = 10
		global_transform.origin.x = 0
		global_transform.origin.z = 0
	if(Input.is_action_just_pressed("mouse")):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if(Input.is_action_just_pressed("remove")):
		var collision = ray.get_collider()
		if(collision != null && collision.has_meta("block")):
			collision.delete()
	
	if Input.is_action_just_pressed("place"):
		var collision = ray.get_collider()
		if(collision != null && collision.has_meta("block")):
			collision.place(ray.get_collision_point())

	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_left"):
		move_vec.x += 1
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))
 
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and Input.is_action_pressed("jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
