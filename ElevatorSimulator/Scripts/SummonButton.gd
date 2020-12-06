extends KinematicBody

var pressed = false
export(int) var level = 0
var height
var green = "ffffff"
var own_color = "fdff00"
var material
var is_inside = false

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
	height = get_parent().global_transform.origin.y
	set_meta("button",true)

func press():
	if !pressed:
		pressed = true
		get_parent().get_parent().get_node("Elevator").add_to_list(self)
