extends RigidBody


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var equipped = false
var state = "none"
var damage = 8
var bullets = 5
var needbullets = 5
var ownray = true
onready var anim_player = $ShotGun/AnimationPlayer2
const BULLET = preload("res://prefabs/Bullet.tscn")
const HIT = preload("res://prefabs/Hit.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

remote func equip():
	visible = true
	equipped = true
	pass

remote func unequip():
	visible = false
	equipped = false
	pass

func _physics_process(delta):
	if(equipped && get_parent().get_parent().get_parent().is_master):
		get_parent().get_parent().get_parent().get_parent().get_node("CanvasLayer/Bullets").text = str(bullets) + "/" + str(needbullets)
		if(Input.is_action_just_pressed("reload") && bullets < needbullets && get_parent().get_parent().get_parent().is_master):
			play_anim("reload")
			rpc("play_anim","reload")

remote func shoot():
	play_anim("shoot")
	$ShotGun/ShootSound.play()
	if(get_parent().get_parent().get_parent().is_master):
		var victims = {}
		for r in range(0,8):
			var ray = get_node("RayCast" + str(r))
			var collision = ray.get_collider()
			if(collision != null && collision.has_meta("player")):
				if !(collision in victims.keys()):
					victims[collision] = damage
				else:
					victims[collision] += damage
			if(collision != null):
				var hit = HIT.instance()
				hit.global_transform.origin = ray.get_collision_point()
				get_parent().get_parent().get_parent().get_parent().add_child(hit)
				hit.emitting = true
				hit.global_scale(Vector3(0.1,0.1,0.1))
				rpc("spawn_hit",hit.global_transform.origin,hit.scale,true)
		for key in victims.keys():
			if(key.health - victims[key] <= 0 && key.time <= 0):
				get_parent().get_parent().get_parent().kills += 1
				get_parent().get_parent().get_parent().get_parent().who_killed_who(get_parent().get_parent().get_parent().ownname, key.ownname)
				get_parent().get_parent().get_parent().rpc("who_killed_who_forall",get_parent().get_parent().get_parent().ownname, key.ownname)
			if(key.time <= 0):
				key.rpc("get_hit",victims[key])
				key.get_hit(victims[key])
	pass

remote func play_anim(anim):
	if(state == anim):
		pass
	anim_player.play(anim)
	if(anim == "shoot"):
		bullets -= 1
	if(anim == "reload"):
		bullets = 5
	state = anim

remote func spawn_hit(position,Scale,emitting):
	var hit = HIT.instance()
	hit.global_transform.origin = position
	hit.emitting = emitting
	hit.global_scale(Scale)
	get_parent().get_parent().get_parent().get_parent().add_child(hit)
