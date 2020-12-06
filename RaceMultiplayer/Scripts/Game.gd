extends Spatial

var players = []

func _process(delta):
	if Net.is_host:
		var really = true
		for p in range(0, len(players)):
			if(!get_node(players[p]).ready):
				really = false
				break
		if(really):
			rpc("reload",1)
			reload(1)

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

remote func update_places(list):
	var playerslist = list
	for p in range(0, len(playerslist)):
		get_node(playerslist[p].name).place = p + 1
		get_node("CanvasLayer/Player" + str(p)).text = str(p + 1) + ". " + playerslist[p].ownname + "\n"
		get_node("CanvasLayer/Player" + str(p)).add_color_override("font_color", playerslist[p].curColor)
	pass

remote func reload(map):
	get_tree().reload_current_scene()
