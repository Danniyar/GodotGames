extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	pass # Replace with function body.

func _physics_process(delta):
	var enemies = []
	for ch in get_children():
		if ch.has_meta("enemy"):
			enemies.append(ch)
	
	if enemies == []:
		get_node("Player").win()
		
