extends Spatial

var players = []
var time = 10

func _process(delta):
	if(time > 0):
		time -= delta
		if(time <= 0):
			time = 10
			for k in range(0,3):
				if(get_node("CanvasLayer/KillInfo" + str(k)).text != ""):
					get_node("CanvasLayer/KillInfo" + str(k)).text  = ""
					break
			

func _ready():
	Net.set_ids()
	create_players()

func create_players():
	for id in Net.peer_ids:
		create_player(id)
	create_player(Net.net_id)

func create_player(id):
	#print("Player with ID " + str(id) + " initialized")
	var p = preload("res://Scenes/Player.tscn").instance()
	add_child(p)
	p.initialize(id)
	players.append(p.name)

remote func update_kills():
	for p in range(0,len(players)):
		get_node("CanvasLayer/Player" + str(p)).text = get_node(str(players[p])).ownname + ": " + str(get_node(str(players[p])).kills) + "   +" + str(get_node(str(players[p])).health) + "+" + "\n"
		get_node("CanvasLayer/Player" + str(p)).add_color_override("font_color",get_node(str(players[p])).curColor)

remote func who_killed_who(name1, name2):
	var killinfo = []
	for k in range(0,3):
		killinfo.append(get_node("CanvasLayer/KillInfo" + str(k)).text)
	killinfo[0] = killinfo[1]
	killinfo[1] = killinfo[2]
	killinfo[2] = name1 + " killed " + name2
	for k in range(0,3):
		get_node("CanvasLayer/KillInfo" + str(k)).text = killinfo[k]
	time = 10
