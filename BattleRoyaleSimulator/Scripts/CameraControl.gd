extends Camera


const ENEMY = preload("res://prefabs/Enemy.tscn")
onready var enemies = []
onready var start = get_parent().get_node("StartingPoint")
var dont = false

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	for a in range(0,25):
		for b in range(0,20):
			var enemy = ENEMY.instance()
			start.add_child(enemy)
			enemy.global_transform.origin = start.global_transform.origin
			enemy.global_transform.origin.x += rand_range(0,140)
			enemy.global_transform.origin.z += rand_range(1,134)
			enemy.rotate_y(rand_range(0,360))
			enemies.append(enemy)
	pass # Replace with function body.

func _process(delta):
	var GUI = get_parent().get_node("CanvasLayer/GUI")
	GUI.get_node("PlayersLeft").text = "Players: " + str(enemies.size())
	if(enemies.size() == 1):
		dont = true
		GUI.get_node("WHOWON").text = str(enemies[0].name) + " HAS WON"
	elif(enemies.size() == 0):
		dont = true
		GUI.get_node("WHOWON").text = "NO ONE HAS WON"
