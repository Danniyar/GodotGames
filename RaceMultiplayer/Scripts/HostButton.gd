extends Button

signal set_connect_type

func _ready():
	pass

func host():
	if(Net.playername != ""):
		get_parent().get_node("MAXPLAYERS").visible = false
		get_parent().get_node("Offline").visible = false
		get_parent().get_node("Name").visible = false
		get_parent().get_node("ColorPicker").visible = false
		get_parent().get_node("SettingsButton").visible = false
		Net.initialize_server()
		emit_signal("set_connect_type", true)
		if(Net.offline):
			begin_game(1)
	else:
		$InvalidName.visible = true
	
remote func begin_game(map):
	get_tree().change_scene("res://Scenes/" + str(map) + ".tscn")
