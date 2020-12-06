extends KinematicBody2D

var MOVE_SPEED = 250
var damage = 40
var health = 50
var can_detect = false
var time = 0.05
onready var state_machine = $AnimationTree.get("parameters/playback")


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.add_animation("rotate",$AnimationPlayer.get_animation("rotate").duplicate())
	$AnimationTree.active = true
	set_meta("enemy",true)
	pass # Replace with function body.


func _process(delta):
	$HPBar.value = health
	if time > 0:
		time -= delta
		if time <= 0:
			can_detect = true
	if !$FloorDetector.is_colliding() && can_detect:
		rotate(-90)
		can_detect = false
		time = 1.1
	var move_dir = Vector2(-1,0).rotated(rotation) * MOVE_SPEED
	move_and_slide(move_dir)

func hit(damage):
	health -= damage
	if health <= 0:
		queue_free()

func _on_Damager_body_entered(body):
	if body.has_meta("player"):
		body.hit(damage)
	pass # Replace with function body.

func rotate(rot):
	var anim = $AnimationPlayer.get_animation("rotate")
	anim.track_set_key_value(0,0,global_position)
	anim.track_set_key_value(1,0,rotation_degrees)
	anim.track_set_key_value(0,1,global_position)
	anim.track_set_key_value(1,1,rotation_degrees + rot)
	play_anim("rotate")

func play_anim(anim_name):
	if state_machine.get_current_node() == anim_name:
		return
	state_machine.travel(anim_name)
