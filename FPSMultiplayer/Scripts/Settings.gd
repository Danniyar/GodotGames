extends Node

var path = "user://data.json"

# The default values
var default_data = {
	"mouse" : {
		"sensivity": 1
	},
	"name": "Player",
	"color": "2f90f9",
	"players": 2,
	"map": 1
}

var data = { }


func _ready():
	load_game()

func load_game():
	var file = File.new()
	
	if not file.file_exists(path):
		reset_data()
		return
	
	file.open(path, file.READ)
	
	var text = file.get_as_text()
	
	data = parse_json(text)
	
	$Sensivity.value = float(data.mouse.sensivity)
	Net.sensivity = $Sensivity.value
	$Sensivity/Value.text = str($Sensivity.value)
	Net.playername = data.name
	get_parent().get_node("Name").text = Net.playername
	Net.cur_color = data.color
	get_parent().get_node("ColorPicker/Color").add_color_override("font_color",data.color)
	Net.MAX_PLAYERS = data.players
	get_parent().get_node("MAXPLAYERS").text = "MAX PLAYERS: " + str(data.players)
	Net.map = data.map
	get_parent().get_node("MapSelect").value = data.map
	get_parent().get_node("MapSelect/Label").text = str(data.map) + " map" 
	
	file.close()


func save_game():
	var file
	
	file = File.new()
	
	file.open(path, File.WRITE)
	
	file.store_line(to_json(data))
	
	file.close()


func reset_data():
	# Reset to defaults
	data = default_data.duplicate(true)



func _on_Sensivity_value_changed(value):
	data.mouse.sensivity = value
	Net.sensivity = value
	$Sensivity/Value.text = str($Sensivity.value)
	save_game()
	pass # Replace with function body.


func _on_Name_text_changed(new_text):
	Net.playername = new_text
	data.name = new_text
	save_game()
	pass # Replace with function body.
