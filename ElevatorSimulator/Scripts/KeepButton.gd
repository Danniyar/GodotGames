extends KinematicBody


var pressed = false
var green = "ffffff"
var own_color = "ffcb00"
var material

func _physics_process(delta):
	if pressed:
		$MeshInstance.material_override.albedo_color = green
	elif !pressed:
		$MeshInstance.material_override.albedo_color = own_color
	pass
	
func _ready():
	material = SpatialMaterial.new()
	material.flags_unshaded = true
	material.albedo_color = own_color
	$MeshInstance.material_override = material
	set_meta("button",true)

func press():
	if !pressed:
		pressed = true

func unpress():
	if pressed:
		pressed = false
