extends KinematicBody

var list = []
var opened = false
var curLevel = null
onready var anim_player = $AnimationPlayer
var target = null
var time = 0

func _ready():
	set_meta("elevator", true)

func _physics_process(delta):
	var buttonlevel = curLevel
	for a in list:
		if a.is_inside && curLevel.level == a.level:
			buttonlevel = a
			break
	if time > 0:
		if anim_player.current_animation != "close" && anim_player.current_animation != "open" && !opened:
			play_anim("go")
		time -= delta
		if time <= 0:
			play_anim("close")
			opened = false
			list.erase(curLevel)
			curLevel.pressed = false
			list.erase(buttonlevel)
			buttonlevel.pressed = false
			anim_player.get_animation("go").track_set_key_value(0,0,global_transform.origin)
	if list != []:
		if (int(global_transform.origin.y) == int(curLevel.height) && !opened && (curLevel in list || buttonlevel in list)) && target != null:
			play_anim("open")
			time = 3
			if target == curLevel || target == buttonlevel:
				target = null
		if target == null && !opened && anim_player.current_animation != "close" && anim_player.current_animation != "open":
			target = list[0]
			var anim = anim_player.get_animation("go")
			anim.track_set_key_value(0,0,global_transform.origin)
			anim.track_set_key_value(0,1,Vector3(global_transform.origin.x, target.height, global_transform.origin.z))
			play_anim("go")

func add_to_list(level):
	list.append(level)

func play_anim(anim):
	if anim == anim_player.current_animation:
		return
	anim_player.play(anim)

func change_opened(par):
	opened = par

func _on_LevelDetector_area_entered(area):
	if area.is_in_group("level"):
		curLevel = area.get_node("SummonButton")
	pass # Replace with function body.
