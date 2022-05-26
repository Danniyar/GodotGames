extends KinematicBody
 
const MOVE_SPEED = 12
const JUMP_FORCE = 15
const GRAVITY = 0.98
const MAX_FALL_SPEED = 30
const HIT = preload("res://prefabs/Hit.tscn")
var health = 100
var ownname = ""
var spawn_point
var shake_amount = 0
var up = false
var curColor

var is_master = false
onready var curWeapon = $Head/CamBase/Garbage

func initialize(id):
	randomize()
	name = str(id)
	ownname = Net.playername
	if id == Net.net_id:
		is_master = true
	if(is_master):
		curColor = Net.cur_color
		spawn_point = get_parent().get_node("SpawnPoint").global_transform.origin
		global_transform.origin = spawn_point
		$Body.visible = false
		$Head/Glasses.visible = false
		var material = SpatialMaterial.new()
		material.albedo_color = curColor
		$Head.material_override = material
		$Body.material_override = material
		material.metallic = 1
		rpc("new_color",curColor,false)
	#print("Player name is " + name)
 
var H_LOOK_SENS = Net.sensivity
var V_LOOK_SENS = Net.sensivity
 
onready var cam = $Head
onready var anim = $Graphics/AnimationPlayer
onready var ray = $Head/CamBase/RayCast
 
var y_velo = 0
var mouseOn = false
var kills = 0
var time = 0
 
func _ready():
	$Head/CamBase/RayCast.add_exception(self)
	set_meta("player",true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _input(event):
	if event is InputEventMouseMotion && is_master:
		cam.rotation_degrees.x += event.relative.y * V_LOOK_SENS
		cam.rotation_degrees.x = clamp(cam.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * H_LOOK_SENS
 
func _physics_process(delta):
	if(is_master):
		randomize()
		if(time > 0):
			time -= delta
			if(time <= 0):
				time = -1
				rpc("new_color",curColor,false)
		if(global_transform.origin.y <= -10):
			global_transform.origin = spawn_point
		if(Input.is_action_just_pressed("1Weapon")):
			change_weapon(1)
			rpc("change_weapon",1)
		if(Input.is_action_just_pressed("2Weapon")):
			change_weapon(2)
			rpc("change_weapon",2)
		if(Input.is_action_just_pressed("3Weapon")):
			change_weapon(3)
			rpc("change_weapon",3)
		get_parent().update_kills()
		if(Input.is_action_pressed("shoot") && !curWeapon.anim_player.is_playing() && curWeapon.bullets > 0):
			if(time > 0):
				time = -1
				rpc("new_color",curColor,false)
			curWeapon.shoot()
			curWeapon.rpc("shoot")
			var collision = $Head/CamBase/RayCast.get_collider()
			if(collision != null && collision.has_meta("player") && !curWeapon.ownray):
				if(collision.health - curWeapon.damage <= 0 && collision.time <= 0):
					kills += 1
					get_parent().who_killed_who(ownname, collision.ownname)
					rpc("who_killed_who_forall", ownname, collision.ownname)
				if(collision.time <= 0):
					collision.rpc("get_hit",curWeapon.damage)
					collision.get_hit(curWeapon.damage)
			if(collision != null && !curWeapon.ownray):
				var hit = HIT.instance()
				hit.global_transform.origin = ray.get_collision_point()
				get_parent().add_child(hit)
				hit.emitting = true
				hit.global_scale(Vector3(0.1,0.1,0.1))
				rpc("spawn_hit",hit.global_transform.origin,hit.scale,true)
		if(Input.is_action_just_pressed("MouseOnOrOff")):
			mouseOn = !mouseOn
			if(mouseOn):
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		var move_vec = Vector3()
		$Head/CamBase.v_offset = 0
		if Input.is_action_pressed("move_forwards"):
			move_vec.z += 1
		if Input.is_action_pressed("move_backwards"):
			move_vec.z -= 1
		if Input.is_action_pressed("move_right"):
			move_vec.x -= 1
		if Input.is_action_pressed("move_left"):
			move_vec.x += 1
		if((Input.is_action_pressed("move_left") || Input.is_action_pressed("move_right") || Input.is_action_pressed("move_backwards") || Input.is_action_pressed("move_forwards")) && is_on_floor()):
			$Head/CamBase.v_offset = shake_amount
			if(up):
				shake_amount += 0.01
				if(Input.is_action_pressed("slow")):
					shake_amount -= 0.005
			else:
				shake_amount -= 0.01
				if(Input.is_action_pressed("slow")):
					shake_amount += 0.005
			if(shake_amount >= 0.1 or shake_amount <= -0.1):
				up = !up
			if(!$Step.is_playing() && !Input.is_action_pressed("slow")):
				$Step.play()
				rpc("step_for_all")
		else:
			shake_amount = 0
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
		move_vec *= MOVE_SPEED
		if(Input.is_action_pressed("slow")):
			move_vec /= MOVE_SPEED
			move_vec *= (MOVE_SPEED/2)
		move_vec.y = y_velo
		move_and_slide(move_vec, Vector3(0, 1, 0))
		rpc_unreliable("update_position", global_transform, cam.rotation_degrees.x)
		rpc_unreliable("update_table",ownname,kills,health,time)
		
		var grounded = is_on_floor()
		y_velo -= GRAVITY
		var just_jumped = false
		if grounded and Input.is_action_pressed("jump"):
			just_jumped = true
			y_velo = JUMP_FORCE
		if grounded and y_velo <= 0:
			y_velo = -0.1
		if y_velo < -MAX_FALL_SPEED:
			y_velo = -MAX_FALL_SPEED

remote func step_for_all():
	$Step.play()

remote func update_position(pos,rot):
	global_transform = pos
	cam.rotation_degrees.x = rot
	
remote func get_hit(damage):
	if(is_master):
		health -= damage
		if(health <= 0):
			health = 100
			global_transform.origin = spawn_point
			time = 3
			rpc("new_color",curColor,true)
		get_parent().get_node("CanvasLayer/Health").text = str(health)

remote func update_table(oname,killss,healthh,timee):
	ownname = oname
	kills = killss
	health = healthh
	time = timee
	get_parent().update_kills()

remote func change_weapon(num):
	if(num == 1):
		curWeapon.unequip()
		curWeapon = $Head/CamBase/Garbage
		curWeapon.equip()
	if(num == 2):
		curWeapon.unequip()
		curWeapon = $Head/CamBase/Pistol
		curWeapon.equip()
	if(num == 3):
		curWeapon.unequip()
		curWeapon = $Head/CamBase/ShotGun
		curWeapon.equip()

remote func spawn_hit(position,Scale,emitting):
	var hit = HIT.instance()
	hit.global_transform.origin = position
	hit.emitting = emitting
	hit.global_scale(Scale)
	get_parent().add_child(hit)

remote func new_color(color,dead):
	curColor = color
	var material = SpatialMaterial.new()
	material.albedo_color = curColor
	if(dead):
		material.flags_transparent = true
		material.albedo_color.a = material.albedo_color.a/2
	material.metallic = 1
	$Head.material_override = material
	$Body.material_override = material

remote func who_killed_who_forall(name1,name2):
	get_parent().who_killed_who(name1, name2)
