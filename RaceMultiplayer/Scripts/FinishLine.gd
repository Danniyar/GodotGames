extends Area

var laps = [[],[],[],[]]
var fullList = []

func _on_FinishLine_body_entered(body):
	if body.has_meta("player"):
		if(body.passes == [true,true,true]):
			if(body.lap == 3):
				body.done = true
			for a in range(3,-1,-1):
				laps[a].erase(body)
			laps[body.lap].append(body)
			if(!body.done):
				body.lap += 1
			body.passes = [false,false,false]
	fullList = laps[3] + laps[2] + laps[1] + laps[0]
	get_parent().update_places(fullList)
	pass # Replace with function body.
