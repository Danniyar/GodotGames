extends Area2D


onready var camera = $SecurityCamera
var player = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if player != null && Input.is_action_just_pressed("ToHide"):
		camera.TurnOff()
		$Sprite.modulate = "ff0000"


func _on_Switch_body_entered(body):
	if body.has_meta("player"):
		$Outline.modulate = "ffffff"
		player = body
	pass # Replace with function body.


func _on_Switch_body_exited(body):
	if body.has_meta("player"):
		$Outline.modulate = "000000"
		player = null
	pass # Replace with function body.
