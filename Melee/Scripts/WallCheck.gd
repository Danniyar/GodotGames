extends RayCast2D
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal changeway()
signal attack()
export(bool) var checkforplayer = true
var timeRemaining = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(delta):
	var collision_object = get_collider()
	if(checkforplayer == false):
		if(collision_object != null && collision_object.name == "Player"):
			emit_signal("attack")
	if(timeRemaining <= 0):
		if(checkforplayer == false):
			if(collision_object != null && collision_object.name == "Blocks"):
				emit_signal("changeway")
				timeRemaining = 0.25
		else:
			if(collision_object != null && collision_object.name == "Player"):
				emit_signal("changeway")
				timeRemaining = 0.25
	else:
		timeRemaining -= delta
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
