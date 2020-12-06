extends KinematicBody2D

var health = 10
export(int) var speed = 50
var no_move = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var pl = get_parent().get_node("Player")
export(int) var whatWeapon = 0
onready var wpn = $Pistol

# Called when the node enters the scene tree for the first time.
func _ready():
	if(whatWeapon == 1):
		wpn = $AutoGun
	elif(whatWeapon == 2):
		wpn = $Knife
	pass # Replace with function body.

func _physics_process(delta):
	var dir = get_angle_to(pl.global_position)
	if abs(dir) < 5:
		rotation += dir
	else:
		if dir>0: rotation += 5 #clockwise
		if dir<0: rotation -= 5 #anit - clockwise
	var velocity = Vector2(1,0).rotated(rotation) * speed
	if(no_move == false):
		move_and_slide(velocity)

func get_hit(hit):
	health -= hit
	if(health <= 0):
		queue_free()

func shoot():
	wpn.play_anim("attack")
