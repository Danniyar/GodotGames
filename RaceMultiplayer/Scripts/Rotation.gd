extends Spatial

var H_LOOK_SENS = 1

var drift = 3
var gainging = false

func _physics_process(delta):
	if(get_parent().is_master):
		get_parent().get_parent().get_node("CanvasLayer/Drift").text = str(drift)
		if(gainging && drift < 3):
			drift += delta
		if(drift >= 3):
			gainging = false
		if(Input.is_action_pressed("drift") && drift > 0 && !gainging && !get_parent().done):
			H_LOOK_SENS = 2
			get_parent().drifting = true
			gainging = false
			drift -= delta
			if(drift <= 0):
				gainging = true
		else:
			H_LOOK_SENS = 1
			get_parent().drifting = false
		global_transform.origin = get_parent().global_transform.origin
		get_parent().rotate_wheels(0)

		if Input.is_action_pressed("move_right") && !get_parent().done :
			if (Input.is_action_pressed("move_forwards") || Input.is_action_pressed("move_backwards") || Input.is_action_pressed("boost")):
				rotation_degrees.y -= H_LOOK_SENS
			get_parent().rotate_wheels(-1)
			get_parent().rpc("rotate_wheels",-1)
		if Input.is_action_pressed("move_left") && !get_parent().done :
			if (Input.is_action_pressed("move_forwards") || Input.is_action_pressed("move_backwards") || Input.is_action_pressed("boost")):
				rotation_degrees.y += H_LOOK_SENS
			get_parent().rotate_wheels(1)
			get_parent().rpc("rotate_wheels",1)
