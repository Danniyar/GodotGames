extends KinematicBody2D
 
const MOVE_SPEED = 125
const GRAVITY = 50
const MAX_FALL_SPEED = 1000
 
onready var sprite = $Head
onready var anim_player = $AnimationPlayer
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var facing_right = false
var player = null

var health = 40
var damage = 5

func _ready():
	$AnimationPlayer.add_animation("attack",$AnimationPlayer.get_animation("attack").duplicate())
	set_meta("enemy", true)
	$AnimationTree.active = true
 
func _physics_process(delta):
	$HPBar.value = health
	var can_move = false
	if state_machine.get_current_node() == "idle":
		can_move = true
	
	var distance = null
	
	if player != null:
		distance = sqrt(pow((player.global_position.x - global_position.x),2) + pow((player.global_position.y - global_position.y),2))
	
	if distance != null && distance <= 150 && can_move:
		var attack = anim_player.get_animation("attack")
		attack.track_set_key_value(0,0,global_position)
		attack.track_set_key_value(0,1,player.global_position)
		attack.track_set_key_value(0,2,global_position)
		play_anim("attack")
		return
	
	var move_dir = Vector2(0,0)
	if player != null && player.global_position.x > global_position.x && can_move:
		move_dir.x += 1
	if player != null && player.global_position.x < global_position.x && can_move:
		move_dir.x -= 1
	move_dir.y = y_velo
	move_dir *= MOVE_SPEED
	move_and_slide(move_dir, Vector2(0, 0))
	
	var grounded = is_on_floor()
	y_velo += GRAVITY
	
	if grounded and y_velo >= 5:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
 
	if facing_right and move_dir.x < 0:
		flip()
	if !facing_right and move_dir.x > 0:
		flip()

 
func flip():
	facing_right = !facing_right
	sprite.scale.y *= -1

func play_anim(anim_name):
	if state_machine.get_current_node() == anim_name:
		return
	state_machine.travel(anim_name)


func _on_PlayerDetector_body_entered(body):
	if body.has_meta("player"):
		player = body
	pass # Replace with function body.


func _on_PlayerDetector_body_exited(body):
	if body.has_meta("player"):
		player = null
	pass # Replace with function body.


func _on_PlayerHIT_body_entered(body):
	if body.has_meta("player"):
		body.hit(damage)
	pass # Replace with function body.

func hit(damage):
	health -= damage
	if health <= 0:
		queue_free()
