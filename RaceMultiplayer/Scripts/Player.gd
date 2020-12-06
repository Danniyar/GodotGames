extends RigidBody
 
const MOVE_SPEED = 40
var ownname = ""
var spawn_point
var curColor = ""
var place = 1
var limit = 10
var lap = 0
var done = true
var ready = false
var time = 3

var is_master = false

func initialize(id):
	randomize()
	name = str(id)
	if id == Net.net_id:
		is_master = true
	if(is_master):
		curColor = Net.cur_color
		ownname = Net.playername
		spawn_point = get_parent().get_node("SpawnPoint").global_transform.origin
		for a in range(1,3):
			for b in range(0,len(Net.colors)/2):
				if(curColor == Net.colors[a*b]):
					spawn_point.x += a*2.5
					spawn_point.z += b*2
		global_transform.origin = spawn_point
		var material = SpatialMaterial.new()
		material.albedo_color = curColor
		material.metallic = 1
		$Car.material_override = material
		$Place.material_override = material
		$Turbo.material_override = material
		rpc("new_color",curColor)
	#print("Player name is " + name)
 
var H_LOOK_SENS = 1

var speed = 0
 
onready var cam = $CamBase

var mouseOn = false

var is_back = false

var drifting = false
var boost = 100
var waiting_for_boost = true
var is_on_ramp = false
var is_on_boost = false

var passes = [true,true,true]

onready var camplace = $CamBase/CamPlace
 
func _ready():
	cam.set_as_toplevel(true)
	set_meta("player",true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
 
func _integrate_forces(state):
	if(is_master):
		var collisions = get_colliding_bodies()
		if(global_transform.origin.y <= -15):
			state.transform.origin = spawn_point
		if(done && Input.is_action_just_pressed("new_game_ready") && time <= 0):
			ready = true
		if(!is_on_ramp):
			rotation_degrees.x = 0
			rotation_degrees.z = 0
		if($DownDetector.get_collider() != null && $DownDetector.get_collider().has_meta("boost")):
			boost = 100
			is_on_boost = true
		else:
			is_on_boost = false
		if($DownDetector.get_collider() != null && $DownDetector.get_collider().has_meta("ramp")):
			look_at($DownDetector.get_collider().global_transform.origin,Vector3.UP)
			is_on_ramp = true
		else:
			is_on_ramp = false
		get_parent().get_node("CanvasLayer/Boost").text = str(int(boost))
		get_parent().get_node("CanvasLayer/Place").text = str(place)
		get_parent().get_node("CanvasLayer/Lap").text = str(lap) + "/3"
		rotation_degrees.y = cam.rotation_degrees.y
		if(Input.is_action_just_pressed("back_view") && !is_back):
			$CamBase/CamPlace.transform.origin.z = -$CamBase/CamPlace.transform.origin.z
			$CamBase/CamPlace.rotation_degrees.y += 180
			is_back = true
		if(Input.is_action_just_released("back_view") && is_back):
			$CamBase/CamPlace.transform.origin.z = -$CamBase/CamPlace.transform.origin.z
			$CamBase/CamPlace.rotation_degrees.y -= 180
			is_back = false
		$CamBase/CamPlace/Camera.global_transform.origin = camplace.global_transform.origin
		if($CamBase/CamPlace/ObstacleDetector.get_collider() != null):
			$CamBase/CamPlace/Camera.global_transform.origin = $CamBase/CamPlace/ObstacleDetector.get_collision_point()
		randomize()
		
		if(Input.is_action_just_pressed("MouseOnOrOff")):
			mouseOn = !mouseOn
			if(mouseOn):
				Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				
		var move_vec = Vector3()
		
		if Input.is_action_pressed("move_forwards") && !done :
			move_vec.z += 1
		if Input.is_action_pressed("move_backwards") && !done :
			move_vec.z -= 1
			
		if(Input.is_action_pressed("boost") && !done && ((int(boost) > 0 && !waiting_for_boost) || (int(boost) > 10 && waiting_for_boost))):
			$CamBase/CamPlace/Camera.fov = 80
			limit = 30
			move_vec.z = 2
			boost -= 0.4
			if(!$Boost.emitting):
				emit(true,10)
				rpc("emit",true,10)
			waiting_for_boost = false
		else:
			emit(false,1)
			rpc("emit",false,1)
			$CamBase/CamPlace/Camera.fov = 70
			limit = 15
			if(int(boost) < 100):
				boost += 0.1
			waiting_for_boost = true
		
		if(drifting && !$Drift.emitting):
			drift(drifting)
			rpc("drift",drifting)
		elif(!drifting && $Drift.emitting):
			drift(drifting)
			rpc("drift",drifting)
		
		move_vec = move_vec.normalized()
		move_vec = move_vec.rotated(Vector3(0, 1, 0), rotation.y)
		move_vec *= MOVE_SPEED
		
		if(linear_velocity.z > limit):
			linear_velocity.z = limit
		elif(linear_velocity.z < -limit):
			linear_velocity.z = -limit
		if(linear_velocity.x > limit):
			linear_velocity.x = limit
		elif(linear_velocity.x < -limit):
			linear_velocity.x = -limit
		
		add_central_force(move_vec)
		
		rpc_unreliable("update_position", global_transform,$FrontWheel1.rotation_degrees.y,ownname,ready,done)

func _physics_process(delta):
	if time > 0 && is_master:
		time -= delta
		get_parent().get_node("CanvasLayer/ReadyTime").text = str(int(time + 1))
		if time <= 0:
			done = false
			get_parent().get_node("CanvasLayer/ReadyTime").text = ""
			rpc("new_color",curColor)

remote func update_position(pos,rot,ownnamee,readyy,donee):
	done = donee
	ownname = ownnamee
	ready = readyy
	global_transform = pos
	$FrontWheel1.rotation_degrees.y = rot
	$FrontWheel2.rotation_degrees.y = rot

remote func rotate_wheels(value):
	if(value > 0):
		$FrontWheel1.rotation_degrees.y = 25
		$FrontWheel2.rotation_degrees.y = 25
	if(value < 0):
		$FrontWheel1.rotation_degrees.y = -25
		$FrontWheel2.rotation_degrees.y = -25
	if(value == 0):
		$FrontWheel1.rotation_degrees.y = 0
		$FrontWheel2.rotation_degrees.y = 0
	
remote func emit(em,am):
	$Boost.emitting = em
	$Boost.amount = am

remote func drift(value):
	$Drift.emitting = value
	$Drift2.emitting = value

remote func new_color(color):
	curColor = color
	var material = SpatialMaterial.new()
	material.albedo_color = curColor
	material.metallic = 1
	$Car.material_override = material
	$Place.material_override = material
	$Turbo.material_override = material

func _on_FloorDetector_area_entered(area):
	for a in range(0,3):
		if area.name == "Pass" + str(a + 1):
			passes[a] = true
	pass # Replace with function body.
