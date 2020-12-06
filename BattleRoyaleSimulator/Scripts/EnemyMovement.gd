extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 30
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
var health = 10
var kills = 0
onready var ray = $RayCast
var mouse_hover = false
var spect = false
onready var cam = $CameraA/Camera
const H_LOOK_SENS = 1.0
const V_LOOK_SENS = 1.0

onready var target = null
var time_left = 1
 
var y_velo = 0

func _ready():
	set_meta("enemy",true)
	$CameraA.set_as_toplevel(true)

func _input(event):
	if event is InputEventMouseMotion:
		if(spect && Input.is_action_pressed("select")):
			$CameraA.rotation_degrees.x -= event.relative.y * V_LOOK_SENS
			$CameraA.rotation_degrees.x = clamp($CameraA.rotation_degrees.x, -90, 90)
			$CameraA.rotation_degrees.y -= event.relative.x * H_LOOK_SENS

func _physics_process(delta):
	$CameraA.global_transform.origin = global_transform.origin
	var GUI = get_parent().get_parent().get_node("CanvasLayer/GUI")
	if(cam.current):
		spect = true
	else:
		spect = false
	if(spect):
		GUI.get_node("Health").text = "Health: " + str(health)
		GUI.get_node("Name").text = "Name: " + self.name
		GUI.get_node("Kills").text = "Kills: " + str(kills)
	if(Input.is_action_just_pressed("select") && mouse_hover):
		if(get_viewport().get_camera() != null):
			get_viewport().get_camera().current = false
		cam.current = true
		spect = true
	elif((Input.is_action_just_pressed("select") && spect) || Input.is_action_just_pressed("global")):
		spect = false
		cam.rotation_degrees = Vector3(0,0,0)
		$CameraA.rotation_degrees = Vector3(0,0,0)
		if(Input.is_action_just_pressed("global")):
			cam.current = false
			get_parent().get_parent().get_node("CamBase").current = true
			GUI.get_node("Health").text = "Health: " + "None"
			GUI.get_node("Name").text = "Name: " + "None"
			GUI.get_node("Kills").text = "Kills: " + "None"
	if(get_parent().get_parent().get_node("CamBase").dont == false):
		if(health <= 5):
			health += 0.1 * delta
		randomize()
		for a in get_slide_count():
			var collision = get_slide_collision(a).collider
			if(collision != null && collision.has_method("get_hit")):
				collision.get_hit(rand_range(1,5))
				if(collision.health <= 0):
					kills += 1
				target = null
			if(collision != null && collision.name != "Floor"):
				rotate_y(180)
		if(target != null):
			look_at(target.global_transform.origin,Vector3.UP)
		else:
			if(time_left <= 0):
				rotate_y(rand_range(-45,45))
				time_left = 0.5
			else:
				time_left -= delta
		var move_vec = Vector3()
		move_vec.z += -1
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

func get_hit(damage):
	var GUI = get_parent().get_parent().get_node("CanvasLayer/GUI")
	health -= damage
	if(health <= 0):
		if(spect):
			GUI.get_node("Health").text = "Health: " + "None"
			GUI.get_node("Name").text = "Name: " + "None"
			GUI.get_node("Kills").text = "Kills: " + "None"
		get_parent().get_parent().get_node("CamBase").enemies.erase(self)
		queue_free()


func _on_Enemy_mouse_entered():
	mouse_hover = true
	pass # Replace with function body.


func _on_Enemy_mouse_exited():
	mouse_hover = false
	pass # Replace with function body.
