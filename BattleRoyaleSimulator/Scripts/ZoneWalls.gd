extends KinematicBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const MOVE_SPEED = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var move_vec = Vector3()
	move_vec.x -= 1
	move_vec = move_vec.normalized()
	move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
	move_vec *= MOVE_SPEED
	if(get_parent().get_node("CamBase").dont == false):
		move_and_slide(move_vec, Vector3(0, 1, 0))
