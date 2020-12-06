extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 15
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 0.5
const V_LOOK_SENS = 0.5
 
onready var cam = $CamBase
onready var ray = $CamBase/RayCast
 
var y_velo = 0
var curLevel = 0
 
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	if get_parent().get_node("Elevator").curLevel != null:
		$CanvasLayer/ElevatorLevel.text = str(get_parent().get_node("Elevator").curLevel.level + 1)
	$CanvasLayer/PlayerLevel.text = str(curLevel + 1)
	if ray.is_colliding() && Input.is_action_just_pressed("press"):
		if ray.get_collider().has_meta("button"):
			ray.get_collider().press()
	if ray.is_colliding() && Input.is_action_just_released("press"):
		if ray.get_collider().has_meta("button"):
			if ray.get_collider().has_method("unpress"):
				ray.get_collider().unpress()
	if Input.is_action_just_pressed("HideShowMouse"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CONFINED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_right"):
		move_vec.x += 1
	if Input.is_action_pressed("move_left"):
		move_vec.x -= 1
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


func _on_LevelDetector_area_entered(area):
	if area.is_in_group("level"):
		curLevel = area.get_node("SummonButton").level
	pass # Replace with function body.
