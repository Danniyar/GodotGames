extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 15
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
 
const H_LOOK_SENS = 0.5
const V_LOOK_SENS = 0.5

var just_teleported = false

var blue_color = "2156fb"
var orange_color = "ff9d00"

var blue_portal = null
var orange_portal = null
 
onready var cam = $CamBase
onready var ray = $CamBase/RayCast
 
var y_velo = 0
func _ready():
	set_meta("player",true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
	if event is InputEventMouseMotion:
		cam.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	if global_transform.origin.y <= -15:
		global_transform.origin = Vector3(-18.842,5.016,-34.744)
	var collisions = $Transparency.get_overlapping_areas()
	var still = false
	for col in collisions:
		if col.get_parent() != null && col.get_parent().has_meta("portal"):
			still = true
	if still:
		set_collision_layer_bit(0,false)
		set_collision_mask_bit(0,false)
		set_collision_layer_bit(1,true)
		set_collision_mask_bit(1,true)
	else:
		just_teleported = false
		set_collision_layer_bit(0,true)
		set_collision_mask_bit(0,true)
		set_collision_layer_bit(1,false)
		set_collision_mask_bit(1,false)
	collisions = $PortalDetector.get_overlapping_areas()
	still = true
	for col in collisions:
		if col.get_parent() != null && col.get_parent().has_meta("portal") && !just_teleported:
			col.get_parent().teleport(self)
		if col.get_parent() != null && col.get_parent().has_meta("portal"):
			still = false
	if Input.is_action_just_pressed("switch"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	var color = ""
	if Input.is_action_just_pressed("blue_portal"):
		color = blue_color
	elif Input.is_action_just_pressed("orange_portal"):
		color = orange_color
	if ray.get_collider() != null && color != "":
		var portal = preload("res://prefabs/Portal.tscn").instance()
		get_parent().add_child(portal)
		portal.global_transform.origin = ray.get_collision_point()
		portal.rotation_degrees = ray.get_collider().rotation_degrees
		portal.scale.x = 1.5
		portal.scale.z = 1.75
		portal.color = color
		portal.new_color()
		if(color == blue_color):
			if(blue_portal != null):
				blue_portal.queue_free()
			blue_portal = portal
		if(color == orange_color):
			if(orange_portal != null):
				orange_portal.queue_free()
			orange_portal = portal
		if(blue_portal != null && orange_portal != null):
			orange_portal.second_portal = blue_portal
			blue_portal.second_portal = orange_portal
			orange_portal.reassign()
			blue_portal.reassign()
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
	if grounded and Input.is_action_just_pressed("jump"):
		just_jumped = true
		y_velo = JUMP_FORCE
	if grounded and y_velo <= 0:
		y_velo = -0.1
	if y_velo < -MAX_FALL_SPEED:
		y_velo = -MAX_FALL_SPEED
