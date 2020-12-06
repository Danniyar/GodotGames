extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_SecurityCamera_body_entered(body):
	if body.has_meta("player"):
		$FieldOfView.modulate = "ad1aff00"
		body.lose()
	pass # Replace with function body.


func _on_SecurityCamera_body_exited(body):
	if body.has_meta("player"):
		$FieldOfView.modulate = "591aff00"
	pass # Replace with function body.

func TurnOff():
	$FieldOfView.visible = false
	$CollisionPolygon2D.disabled = true
