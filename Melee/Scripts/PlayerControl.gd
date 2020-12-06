extends KinematicBody2D
 
const MOVE_SPEED = 500
const JUMP_FORCE = 1250
const GRAVITY = 50
const MAX_FALL_SPEED = 1000
var state = "idle"
var health = 3
 
onready var anim_player = $AnimationPlayer
onready var sprite = $Torso
 
var y_velo = 0
var facing_right = true

func _physics_process(delta):
	for i in get_slide_count():
		var collision = get_slide_collision(i)
	var move_dir = 0
	if Input.is_action_pressed("move_right") && state != "attack" && state != "defence":
		move_dir += 1
		sprite.scale.x = abs(sprite.scale.x)
	if Input.is_action_pressed("move_left") && state != "attack" && state != "defence":
		move_dir -= 1
		sprite.scale.x = -abs(sprite.scale.x)
	move_and_slide(Vector2(move_dir * MOVE_SPEED, y_velo), Vector2(0, -1))
 
	var grounded = is_on_floor()
	if(is_on_ceiling()):
		y_velo = 0
	y_velo += GRAVITY
	if grounded and Input.is_action_just_pressed("move_up") && state != "attack" && state != "defence":
		$JumpSound.play()
		y_velo = -JUMP_FORCE
	if grounded and y_velo >= 5:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
	
	if(Input.is_action_pressed("attack")):
		play_anim("attack")
	elif(Input.is_action_pressed("defence")):
		play_anim("defence")
	elif grounded:
		if move_dir == 0:
			play_anim("idle")
		else:
			play_anim("run")
	else:
		play_anim("jump")
 
func play_anim(anim_name):
	if state == anim_name:
		return
	anim_player.play(anim_name)
	state = anim_name


func _on_HandHitArea_body_entered(body):
	if(body.has_method("get_hit") && state == "attack"):
		body.get_hit()

func get_hit():
	if(state != "defence"):
		$HitSound.play()
		health -= 1
	get_parent().get_node("CanvasLayer/GUI/Health").text = "Health: " + str(health)
	if(health <= 0):
		get_tree().reload_current_scene()
