extends Spatial

const CHUNK = preload("res://prefabs/Chunk.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(0,1):
		for y in range(0,1):
			var ch = CHUNK.instance()
			add_child(ch)
			ch.global_transform = global_transform
			ch.global_transform.origin.x += x * 32
			ch.global_transform.origin.y += y * 32
	pass # Replace with function body.
