extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Quit_pressed():
	get_tree().quit()
	pass # Replace with function body.


func _on_Play_pressed():
	$PlayScreen.visible = true
	$MenuScreen.visible = false
	pass # Replace with function body.


func _on_Tutorial_pressed():
	get_tree().change_scene("res://Tutorial.tscn")
	pass # Replace with function body.


func _on_Level1_pressed():
	get_tree().change_scene("res://Level1.tscn")
	pass # Replace with function body.


func _on_Back_pressed():
	$PlayScreen.visible = false
	$MenuScreen.visible = true
	pass # Replace with function body.


func _on_Level2_pressed():
	get_tree().change_scene("res://Level2.tscn")
	pass # Replace with function body.


func _on_Level3_pressed():
	get_tree().change_scene("res://Level3.tscn")
	pass # Replace with function body.


func _on_Level4_pressed():
	get_tree().change_scene("res://Level4.tscn")
	pass # Replace with function body.


func _on_Level5_pressed():
	get_tree().change_scene("res://Level5.tscn")
	pass # Replace with function body.
