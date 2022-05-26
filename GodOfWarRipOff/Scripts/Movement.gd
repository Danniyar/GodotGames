extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 15
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 0.5
const V_LOOK_SENS = 0.5
 
onready var cam = $CamBase
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var is_thrown = false
var inherit = true
var moving = false
var saved_rotation = null
 
func _ready():
	$Skeleton/BoneAttachment/Axe.add_collision_exception_with(self)
	$Skeleton/BoneAttachment/Axe.set_as_toplevel(true)
	$AnimationTree.active = true
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
	for body in $Skeleton/BoneAttachment/Axe/Detector.get_overlapping_bodies():
		if body.is_in_group("nodestruction") && is_thrown && $Skeleton/BoneAttachment/Axe/AnimationPlayer.current_animation != "return":
			if moving:
				$Skeleton/BoneAttachment/Axe/Hit.play()
			$Skeleton/BoneAttachment/Axe/ThrowEffect.emitting = true
			moving = false
	for body in $Skeleton/BoneAttachment/Axe/Detector.get_overlapping_areas():
		if body.is_in_group("destructable") && is_thrown:
			body.get_node("destruction").destroy()
			if moving:
				$Skeleton/BoneAttachment/Axe/Break.play()
	if inherit:
		$Skeleton/BoneAttachment/Axe.global_transform = $Skeleton/BoneAttachment/AxePosition.global_transform
	if moving:
		$Skeleton/BoneAttachment/Axe.rotate_object_local(Vector3(1,0,0),20*delta)
		$Skeleton/BoneAttachment/Axe.move_and_slide(-saved_rotation/1.5*50)
	if Input.is_action_just_pressed("switch"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_just_pressed("throw") && !is_thrown:
		play_anim("ThrowAxe")
	if is_thrown && Input.is_action_just_pressed("catch"):
		moving = true
		var anim = $Skeleton/BoneAttachment/Axe/AnimationPlayer.get_animation("return")
		anim.track_set_key_value(1,0,$Skeleton/BoneAttachment/Axe.global_transform.origin)
		anim.track_set_key_value(1,1,$CamBase/Camera/CurvePoint.global_transform.origin)
		anim.track_set_key_value(1,2,$Skeleton/BoneAttachment/AxePosition.global_transform.origin)
		$Skeleton/BoneAttachment/Axe/AnimationPlayer.play("return")
		$Skeleton/BoneAttachment/Axe.rotation = rotation
	var can_move = false
	if state_machine.get_current_node() == "idle" || state_machine.get_current_node() == "walk":
		can_move = true
	var move_vec = Vector3()
	if Input.is_action_pressed("move_forwards"):
		move_vec.z += 1
	if Input.is_action_pressed("move_backwards"):
		move_vec.z -= 1
	if Input.is_action_pressed("move_right"):
		move_vec.x -= 1
	if Input.is_action_pressed("move_left"):
		move_vec.x += 1
	if !can_move:
		move_vec.x = 0
		move_vec.z = 0
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	move_vec.y = y_velo
	move_and_slide(move_vec, Vector3(0, 1, 0))
 
	var grounded = is_on_floor()
	y_velo -= GRAVITY
	var just_jumped = false
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
 
	if grounded:
		if move_vec.x == 0 and move_vec.z == 0:
			play_anim("idle")
		else:
			play_anim("walk")
 
func play_anim(name):
	if state_machine.get_current_node() == name:
		return
	state_machine.travel(name)

func ThrowAxe():
	$Skeleton/BoneAttachment/Axe/Throw.play()
	is_thrown = true
	inherit = false
	$Skeleton/BoneAttachment/Axe.rotation = rotation
	saved_rotation = cam.global_transform.basis.z
	moving = true

func CatchAxe():
	$Skeleton/BoneAttachment/Axe/Catch.play()
	randomize()
	$Skeleton/BoneAttachment/CatchEffect.emitting = true
	is_thrown = false
	inherit = true
	moving = false
	var anim = $CamBase/Camera/AnimationPlayer.get_animation("ScreenShake")
	$CamBase/Camera/AnimationPlayer.play("ScreenShake")
