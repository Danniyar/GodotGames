extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(bool) var cango = true
var time = 10
var green = "7c5cff00"
var red = "7cff0000"
var nmaterial

# Called when the node enters the scene tree for the first time.
func _ready():
	nmaterial = SpatialMaterial.new()
	nmaterial.flags_transparent = true
	nmaterial.metallic = 1
	if(cango):
		nmaterial.albedo_color = green
	else:
		nmaterial.albedo_color = red
	$MeshInstance.material_override = nmaterial
	set_meta("light",true)
	pass # Replace with function body.

func _physics_process(delta):
	for collision in get_overlapping_bodies():
		if(collision.has_meta("car")):
			collision.can_move = cango
	time -= delta
	if(time <= 0):
		time = 10
		cango = !cango
		if(cango):
			nmaterial.albedo_color = green
		else:
			nmaterial.albedo_color = red
		$MeshInstance.material_override = nmaterial
