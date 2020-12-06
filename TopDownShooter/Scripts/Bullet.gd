extends KinematicBody2D

var MOVE_SPEED = 1000
var damage = 2
var isEnemy = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	for i in get_slide_count():
		var collision = get_slide_collision(i).collider
		if(collision != null && collision.has_method("get_hit") && ((collision.name == "Player" && isEnemy) || collision.name != "Player")):
			collision.get_hit(damage)
		if(collision != null && ((collision.name == "Player" && isEnemy) || collision.name != "Player")):
			queue_free()
		break
	var velocity = Vector2(0, -1).rotated(rotation) * MOVE_SPEED
	move_and_slide(velocity)

func set_speed(speed):
	MOVE_SPEED = speed

func set_damage(DAMAGE):
	damage = DAMAGE
