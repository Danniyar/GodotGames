extends Node

var path = "user://data.json"

# The default values
var default_data = {
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

	Net.playername = data.name
	get_parent().get_node("Name").text = Net.playername
	Net.cur_color = data.color
	get_parent().get_node("ColorPicker/Color").add_color_override("font_color",data.color)
	Net.MAX_PLAYERS = data.players
	get_parent().get_node("MAXPLAYERS").text = "MAX PLAYERS: " + str(data.players)
	
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


func _on_Name_text_changed(new_text):
	Net.playername = new_text
	data.name = new_text
	save_game()
	pass # Replace with function body.
