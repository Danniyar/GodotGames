extends KinematicBody
 
var MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
var spect = false
onready var cam = $CameraA/Camera
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0
var y_velo = 0
var can_move = true
export(int) var type = 0
onready var ray = $RayCast

var mouse_hover = false

func _ready():
	set_meta("car",true)
	$CameraA.set_as_toplevel(true)

func _input(event):
	if event is InputEventMouseMotion:
		if(spect && Input.is_action_pressed("select")):
			$CameraA.rotation_degrees.y -= event.relative.x * H_LOOK_SENS

func _physics_process(delta):
	var raycollision = ray.get_collider()
	if(raycollision != null):
		if(raycollision.has_meta("car")):
			raycollision.can_move = can_move
	$CameraA.global_transform.origin = global_transform.origin
	if(cam.current):
		spect = true
	else:
		spect = false
	if(Input.is_action_just_pressed("select") && mouse_hover):
		if(get_viewport().get_camera() != null):
			get_viewport().get_camera().current = false
		cam.current = true
		spect = true
	elif((Input.is_action_just_pressed("select") && spect) || Input.is_action_just_pressed("global")):
		spect = false
		$CameraA.rotation_degrees = Vector3(0,0,0)
		if(Input.is_action_just_pressed("global")):
			cam.current = false
			get_parent().get_parent().get_node("CamBase").current = true
	if(get_parent().get_parent().get_node("CamBase").dont == false):
		randomize()
		for a in get_slide_count():
			var collision = get_slide_collision(a).collider
			if(collision != null && collision.has_method("die")):
				collision.die()
				die()
		var move_vec = Vector3()
		if(can_move):
			move_vec.x -= 1
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
		move_vec *= MOVE_SPEED
		move_vec.y = y_velo
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

func die():
	queue_free()

func _on_Car_mouse_entered():
	mouse_hover = true
	pass # Replace with function body.


func _on_Car_mouse_exited():
	mouse_hover = false
	pass # Replace with function body.
