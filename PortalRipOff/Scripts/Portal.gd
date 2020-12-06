extends MeshInstance
 
onready var dummy_cam = $DummyCam
onready var mirror_cam = $Viewport/Camera

var fix = 0

var color

onready var second_portal = self

func _physics_process(delta):
	pass

func _ready():
	reassign()
	$AnimationPlayer.play("spawn")
 
func reassign():
	set_meta("portal", true)
	add_to_group("portals")
	material_override = preload("res://Portal.tres").duplicate()
	material_override.set_shader_param("refl_tx", $Viewport.get_texture())
	fix = second_portal.rotation_degrees.y + rotation_degrees.y
	$Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
 
func update_cam(main_cam_transform):
	scale.y *= -1
	dummy_cam.global_transform = main_cam_transform
	scale.y *= -1
	mirror_cam.global_transform = dummy_cam.global_transform
	mirror_cam.global_transform.origin = second_portal.global_transform.origin
	mirror_cam.rotation_degrees.y += fix
	mirror_cam.rotation_degrees.y *= -1
	mirror_cam.global_transform.basis.x *= -1
	if !(int(abs(round(rotation_degrees.y / 90) * 90)) % 180 == 0) && scale.y > 0:
		scale.y *= -1

func teleport(body):
	body.rotation_degrees.y = mirror_cam.rotation_degrees.y
	var posFix = body.global_transform.origin - global_transform.origin
	body.global_transform.origin = second_portal.global_transform.origin + posFix
	body.just_teleported = true
	pass # Replace with function body.

func new_color():
	var mat = SpatialMaterial.new()
	mat.albedo_color = color
	mat.metallic = 1
	mat.flags_unshaded = true
	$Edge2/MeshInstance.material_override = mat
	$Edge2/MeshInstance2.material_override = mat
	$Edge3/MeshInstance.material_override = mat
	$Edge4/MeshInstance.material_override = mat
