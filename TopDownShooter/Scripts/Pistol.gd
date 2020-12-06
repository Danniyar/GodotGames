extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var anim_player = $AnimationPlayer
export(bool) var isEnemy = false
var state = "nothing"
var status = "unequipped"
export(float) var damage = 2
const BULLET = preload("res://prefabs(?)/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _process(delta):
	if(Input.is_action_pressed("attack") && status == "equipped" && isEnemy == false):
		play_anim("attack")
	elif(state == "attack" && anim_player.is_playing() == false):
		play_anim("nothing")
	if(Input.is_action_just_pressed("unequip_weapon") && state != "attack" && status == "equipped" && isEnemy == false):
		unequip()

func play_anim(anim_name):
	if state == anim_name:
		return
	if(anim_name == "attack"):
		var bullet = BULLET.instance()
		bullet.isEnemy = isEnemy
		bullet.global_transform = global_transform
		bullet.damage = damage
		get_parent().get_parent().add_child(bullet)
	anim_player.play(anim_name)
	state = anim_name

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
