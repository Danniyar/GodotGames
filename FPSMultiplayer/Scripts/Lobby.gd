extends Control

var current_players = 1

func _ready():
	get_tree().connect("connected_to_server", self, "connected")

func connected():
	if Net.is_host and Net.current_players == Net.MAX_PLAYERS:
		rpc("begin_game",Net.map)
		begin_game(Net.map)
	else:
		if not Net.is_host:
			rpc_id(0, "player_joined",Net.net_id)

remote func begin_game(map):
	get_tree().change_scene("res://Scenes/" + str(map) + ".tscn")

remote func player_joined(sender):
	print("PLAYER CONNECTED")
	Net.current_players += 1
	current_players = Net.current_players
	connected()

func _on_Down_pressed():
	if(Net.MAX_PLAYERS > 2):
		Net.MAX_PLAYERS -= 1
	$MAXPLAYERS.text = "MAX PLAYERS: " + str(Net.MAX_PLAYERS)
	$Settings.data.players = Net.MAX_PLAYERS
	$Settings.save_game()
	pass # Replace with function body.


func _on_Up_pressed():
	if(Net.MAX_PLAYERS < 8):
		Net.MAX_PLAYERS += 1
	$MAXPLAYERS.text = "MAX PLAYERS: " + str(Net.MAX_PLAYERS)
	$Settings.data.players = Net.MAX_PLAYERS
	$Settings.save_game()
	pass # Replace with function body.


func _on_Offline_pressed():
	Net.offline = !Net.offline
	pass # Replace with function body.


func _on_ColorPicker_value_changed(value):
	if(value == 0):
		$ColorPicker/Color.add_color_override("font_color",Net.blue)
		Net.cur_color = Net.blue
	elif(value == 1):
		$ColorPicker/Color.add_color_override("font_color",Net.green)
		Net.cur_color = Net.green
	elif(value == 2):
		$ColorPicker/Color.add_color_override("font_color",Net.pink)
		Net.cur_color = Net.pink
	elif(value == 3):
		$ColorPicker/Color.add_color_override("font_color",Net.red)
		Net.cur_color = Net.red
	elif(value == 4):
		$ColorPicker/Color.add_color_override("font_color",Net.black)
		Net.cur_color = Net.black
	elif(value == 5):
		$ColorPicker/Color.add_color_override("font_color",Net.white)
		Net.cur_color = Net.white
	elif(value == 6):
		$ColorPicker/Color.add_color_override("font_color",Net.yellow)
		Net.cur_color = Net.yellow
	elif(value == 7):
		$ColorPicker/Color.add_color_override("font_color",Net.purple)
		Net.cur_color = Net.purple
	$Settings.data.color = Net.cur_color
	$Settings.save_game()
	pass # Replace with function body.


func _on_SettingsButton_pressed():
	$Settings.visible = !$Settings.visible
	$ColorPicker.visible = !$ColorPicker.visible
	$MAXPLAYERS.visible = !$MAXPLAYERS.visible
	$Offline.visible = !$Offline.visible
	pass # Replace with function body.


func _on_MapSelect_value_changed(value):
	$MapSelect/Label.text = str(value) + " map" 
	Net.map = value
	$Settings.data.map = value
	$Settings.save_game()
	pass # Replace with function body.
