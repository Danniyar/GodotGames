extends KinematicBody2D
 
const MOVE_SPEED = 500
const JUMP_FORCE = 1000
const GRAVITY = 50
const MAX_FALL_SPEED = 1000
 
onready var sprite = $Torso
onready var anim_player = $AnimationPlayer
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var facing_right = true

var state = "seeking"
var curSpot = null

export(int) var nextLevel = 1

var savedPosition = null

var jumps = 2

func _ready():
	set_meta("player", true)
	$AnimationTree.active = true
 
func _physics_process(delta):
	var can_move = false
	if state_machine.get_current_node() == "idle" || state_machine.get_current_node() == "walk" || state_machine.get_current_node() == "jump":
		can_move = true
	var move_dir = 0
	if Input.is_action_pressed("move_right"):
		move_dir += 1
	if Input.is_action_pressed("move_left"):
		move_dir -= 1
	if Input.is_action_just_pressed("ToHide") && curSpot != null && state == "seeking" && can_move:
		var anim = anim_player.get_animation("ToHide")
		savedPosition = global_position
		anim.track_set_key_value(0,0,scale)
		anim.track_set_key_value(0,1,Vector2(0.01,0.01))
		anim.track_set_key_value(1,0,global_position)
		anim.track_set_key_value(1,1,curSpot.global_position)
		$TransformSound.play()
		play_anim("ToHide")
	if Input.is_action_just_pressed("ToSeek") && state == "hiding":
		var anim = anim_player.get_animation("ToSeek")
		anim.track_set_key_value(0,0,scale)
		anim.track_set_key_value(0,1,Vector2(0.1,0.1))
		anim.track_set_key_value(1,0,global_position)
		anim.track_set_key_value(1,1,savedPosition)
		$TransformSound.play()
		play_anim("ToSeek")

	if state == "seeking" && can_move:
		move_and_slide(Vector2(move_dir * MOVE_SPEED, y_velo), Vector2(0, -1))
 
	var grounded = is_on_floor()
	if grounded:
		jumps = 2
	if is_on_ceiling():
		y_velo = 0
	y_velo += GRAVITY
	if Input.is_action_just_pressed("jump") && jumps > 0:
		y_velo = -JUMP_FORCE
		jumps -= 1
		$JumpSound.play()
		
	if grounded && y_velo >= 5:
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
	
 
func flip():
	facing_right = !facing_right
	sprite.scale.x = -sprite.scale.x

func play_anim(anim_name):
	if state_machine.get_current_node() == anim_name:
		return
	state_machine.travel(anim_name)

func make_seek():
	$CollisionShape2D.disabled = false
	state = "seeking"

func make_hide():
	$CollisionShape2D.disabled = true
	state = "hiding"


func _on_SpotFinder_area_entered(area):
	if area.is_in_group("HidingSpot"):
		curSpot = area
		curSpot.get_child(0).modulate = "828282"
	pass # Replace with function body.


func _on_SpotFinder_area_exited(area):
	if area == curSpot:
		curSpot.get_child(0).modulate = "000000"
		curSpot = null
	pass # Replace with function body.


func _on_EnemyFinder_body_entered(body):
	if body.has_meta("enemy") && y_velo > 1 && state == "seeking":
		body.die()
		y_velo = -JUMP_FORCE/1.5
		$HitSound.play()
	pass # Replace with function body.

func lose():
	$CanvasLayer/DeadScreen.visible = true
	get_tree().paused = true
	$CaughtSound.play()
	pass

func win():
	$CanvasLayer/WinScreen.visible = true
	get_tree().paused = true
	pass


func _on_Menu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menu.tscn")
	pass # Replace with function body.


func _on_Retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
	pass # Replace with function body.


func _on_BackToMenu_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Menu.tscn")
	pass # Replace with function body.


func _on_NextLevel_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://Level" + str(nextLevel) + ".tscn")
	pass # Replace with function body.
