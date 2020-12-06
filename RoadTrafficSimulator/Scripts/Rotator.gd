extends Area


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(int) var type = 0
var nmaterial
# Called when the node enters the scene tree for the first time.
func _ready():
	nmaterial = SpatialMaterial.new()
	nmaterial.albedo_color = Color(0,5*type,10*type)
	$MeshInstance.material_override = nmaterial
	pass # Replace with function body.

func _physics_process(delta):
	for collision in get_overlapping_bodies():
		if(collision.has_meta("car") && collision.type == type && (int(collision.global_transform.origin.x) == int(global_transform.origin.x) && int(collision.global_transform.origin.z) == int(global_transform.origin.z))):
			collision.rotation_degrees.y = rotation_degrees.y

