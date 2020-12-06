extends KinematicBody2D
 
const MOVE_SPEED = 250
const JUMP_FORCE = 1000
const GRAVITY = 50
const MAX_FALL_SPEED = 1000

const Particle = preload("res://prefabs/DeathEffect.tscn")
 
onready var sprite = $Torso
onready var anim_player = $AnimationPlayer
onready var state_machine = $AnimationTree.get("parameters/playback")
 
var y_velo = 0
var facing_right = false
export(bool) var tutorial = false

func _ready():
	anim_player.add_animation("rotate",anim_player.get_animation("rotate").duplicate())
	set_meta("enemy", true)
	$AnimationTree.active = true
 
func _physics_process(delta):
	var collisions = get_slide_count()
	for col in collisions:
		if get_slide_collision(col).has_meta("player") && get_slide_collision(col).y_velo <= 1:
			get_slide_collision(col).lose()
	var move_dir = 0
	if facing_right:
		move_dir += 1
	if !facing_right:
		move_dir -= 1

	move_and_slide(Vector2(move_dir * MOVE_SPEED, y_velo), Vector2(0, -1))
 
	var grounded = is_on_floor()
	if is_on_ceiling():
		y_velo = 0
	y_velo += GRAVITY
		
	if grounded && y_velo >= 5:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
 
	if facing_right and move_dir < 0:
		flip()
	if !facing_right and move_dir > 0:
		flip()
	
	if grounded:
		play_anim("roll")
	
 
func flip():
	var anim = anim_player.get_animation("rotate")
	anim.track_set_key_value(0,0,global_position)
	anim.track_set_key_value(0,1,global_position)
	anim.track_set_key_value(1,0,Vector2(sprite.scale.x,sprite.scale.y))
	anim.track_set_key_value(1,1,Vector2(-sprite.scale.x,sprite.scale.y))
	facing_right = !facing_right
	play_anim("rotate")

func play_anim(anim_name):
	if state_machine.get_current_node() == anim_name:
		return
	state_machine.travel(anim_name)


func _on_WallDetector_body_entered(body):
	if "Wall" in body.name:
		flip()
	pass # Replace with function body.

func die():
	var par = Particle.instance()
	get_parent().add_child(par)
	par.emitting = true
	par.global_position = global_position
	par.global_rotation = -90
	par.scale = Vector2(3,3)
	queue_free()


func _on_PlayerDetector_body_entered(body):
	if body.has_meta("player"):
		$Torso/PlayerDetector/Sprite.modulate = "ad1aff00"
		if !tutorial:
			body.lose()
	pass # Replace with function body.


func _on_PlayerDetector_body_exited(body):
	if body.has_meta("player"):
		$Torso/PlayerDetector/Sprite.modulate = "591aff00"
	pass # Replace with function body.
