extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(bool) var isEnemy = false
var status = "unequipped"
export(float) var damage = 2
var curbul = null
const BULLET = preload("res://prefabs(?)/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if(Input.is_action_pressed("attack") && status == "equipped" && isEnemy == false):
		charge(delta)
	if(Input.is_action_just_released("attack") && status == "equipped" && isEnemy == false && curbul != null):
		get_parent().remove_child(curbul)
		curbul = null
	if(Input.is_action_just_pressed("unequip_weapon") && status == "equipped" && isEnemy == false):
		unequip()

func shoot():
	curbul.MOVE_SPEED = 1000
	get_parent().remove_child(curbul)
	get_parent().get_parent().add_child(curbul)
	curbul.global_position = global_position
	curbul.global_rotation = global_rotation
	curbul = null

func charge(delta):
	if(curbul == null):
		curbul = BULLET.instance()
		curbul.MOVE_SPEED = 0
		curbul.damage = 0.01
		curbul.global_transform = global_transform
		get_parent().add_child(curbul)
		curbul.global_transform = global_transform
	if(curbul.damage < 7):
		curbul.scale.x += delta * 2
		curbul.scale.y += delta * 2
		curbul.damage += delta * 4
	else:
		shoot()

func equip(new_parent):
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = new_parent.WeaponPlace()
	global_rotation = new_parent.WeaponRotation()
	status = "equipped"
	$Area2D/CollisionShape2D.disabled = true

func unequip():
	var new_parent = get_parent().get_parent()
	if(get_parent().has_method("unequip")):
		get_parent().unequip()
	var old_position = global_position
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = old_position
	status = "unequiped"
	$Area2D/CollisionShape2D.disabled = false
