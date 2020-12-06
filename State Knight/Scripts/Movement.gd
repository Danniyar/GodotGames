extends KinematicBody2D
 
const MOVE_SPEED = 500
const JUMP_FORCE = 1000
const GRAVITY = 50
const MAX_FALL_SPEED = 1000
const blue = "2f90f9"
const red = "f5130a"
const green = "33f541"
const SwordShoot = preload("res://prefabs/SwordShoot.tscn")
 
onready var sprite = $Torso
onready var anim_player = $AnimationPlayer
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var facing_right = false

var health = 100
var power = 100
var damage = 20
var state = "normal"
var powerdown = false
var jumps = 2

func _ready():
	set_meta("player", true)
	$AnimationTree.active = true
 
func _physics_process(delta):
	if Input.is_action_pressed("heal") && !powerdown && health < 100:
		health += 0.2
		power -= 1
	if state != "normal" && !powerdown:
		power -= 0.5
	if power < 100 && state == "normal":
		power += 0.5
	if power > 25:
		powerdown = false
	if Input.is_action_just_pressed("attack_state") && state != "attack":
		state = "attack"
		$Camera2D/CanvasLayer/State.text = state
		$Camera2D/CanvasLayer/State.add_color_override("font_color", red)
		explode(red)
		$StateChangeSound.play()
	if Input.is_action_just_pressed("defence_state") && state != "defence":
		state = "defence"
		$Camera2D/CanvasLayer/State.text = state
		$Camera2D/CanvasLayer/State.add_color_override("font_color", blue)
		explode(blue)
		$StateChangeSound.play()
	if Input.is_action_just_pressed("normal_state") && state != "normal":
		state = "normal"
		$Camera2D/CanvasLayer/State.text = state
		$Camera2D/CanvasLayer/State.add_color_override("font_color", green)
		explode(green)
		$StateChangeSound.play()
	$Camera2D/CanvasLayer/HPBar.value = health
	$Camera2D/CanvasLayer/PWBar.value = power
	var can_move = false
	var can_jump = false
	if state_machine.get_current_node() == "idle" || state_machine.get_current_node() == "walk" || state_machine.get_current_node() == "jump":
		can_move = true
		can_jump = true
	if state_machine.get_current_node() == "attack" && !is_on_floor():
		can_move = true
	var move_dir = 0
	if Input.is_action_pressed("move_right") && can_move:
		move_dir += 1
	if Input.is_action_pressed("move_left") && can_move:
		move_dir -= 1
	move_and_slide(Vector2(move_dir * MOVE_SPEED, y_velo), Vector2(0, -1))
 
	var grounded = is_on_floor()
	if grounded:
		jumps = 2
	if is_on_ceiling():
		y_velo = 0
	y_velo += GRAVITY
	if Input.is_action_just_pressed("jump") && jumps > 0 && can_jump:
		y_velo = -JUMP_FORCE
		jumps -= 1
		$JumpSound.play()
	if grounded and y_velo >= 5:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
 
	if facing_right and move_dir < 0:
		flip()
	if !facing_right and move_dir > 0:
		flip()
	
	if grounded:
		if move_dir == 0:
			play_anim("idle")
		else:
			play_anim("walk")
	else:
		play_anim("jump")
	
	if power <= 0:
		powerdown = true
	
	if Input.is_action_just_pressed("attack") && !powerdown && state == "attack":
		var attack = $AnimationPlayer.get_animation("attack")
		attack.track_set_key_value(6, 0, {"args":[false], "method":"Shoot"})
		play_anim("attack")
	
	if Input.is_action_just_pressed("heavy_attack") && power >= 70 && state == "attack":
		var attack = $AnimationPlayer.get_animation("attack")
		attack.track_set_key_value(6, 0, {"args":[true], "method":"Shoot"})
		play_anim("attack")
 
func flip():
	facing_right = !facing_right
	sprite.scale.x = -sprite.scale.x
	$StateEffect.scale.x = -$StateEffect.scale.x

func play_anim(anim_name):
	if state_machine.get_current_node() == anim_name:
		return
	state_machine.travel(anim_name)

func explode(color):
	$StateEffect.restart()
	$StateEffect.process_material.color = color

func hit(damage):
	if state != "defence" || powerdown:
		health -= damage
	if health <= 0:
		get_tree().change_scene("res://World.tscn")


func _on_Sword_body_entered(body):
	if body.has_meta("enemy"):
		body.hit(damage)
		$HitSound.play()
	pass # Replace with function body.

func Shoot(shoot):
	if shoot:
		var shot = SwordShoot.instance()
		get_parent().add_child(shot)
		shot.global_position.x = $Torso/LeftArm/Sword.global_position.x
		shot.global_position.y = global_position.y
		shot.right = facing_right
		power = 0
