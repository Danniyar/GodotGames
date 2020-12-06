extends RayCast2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var timeRemaining = 0
var Reload = false
export(float) var timetoReload = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if(Reload):
		if(timeRemaining > 0):
			timeRemaining -= delta
		else:
			Reload = false
	var collision = get_collider()
	if(collision != null):
		if(collision.name == "Player" && Reload == false):
			get_parent().shoot()
			timeRemaining = timetoReload
			Reload = true
		if(collision.name == "Player"):
			get_parent().no_move = true
		if(collision.name != "Player"):
			get_parent().no_move = false
	else:
		get_parent().no_move = false
