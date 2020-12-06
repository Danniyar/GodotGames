extends KinematicBody

var pressed = false
export(int) var level = 0
var height = null
var green = "ffffff"
var own_color = "fdff00"
var material
var is_inside = true

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
	height = get_parent().get_parent().get_node("Level" + str(level + 1)).global_transform.origin.y
	set_meta("button",true)

func press():
	if !pressed:
		pressed = true
		get_parent().add_to_list(self)
