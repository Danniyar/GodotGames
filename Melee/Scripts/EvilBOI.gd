extends KinematicBody2D

var health = 3
 
const MOVE_SPEED = 250
const JUMP_FORCE = 1250
const GRAVITY = 50
const MAX_FALL_SPEED = 1000
var state = "idle"
var way = 1
var attacking = false
 
onready var anim_player = $AnimationPlayer
onready var sprite = $Torso
 
var y_velo = 0
var facing_right = true

func _ready():
	set_meta("enemy",true)
func _physics_process(delta):
	for i in get_slide_count():
		var collision = get_slide_collision(i)
	var move_dir = 0
	if way > 0 && state != "attack":
		move_dir += 1
		sprite.scale.x = abs(sprite.scale.x)
	if way < 0 && state != "attack":
		move_dir -= 1
		sprite.scale.x = -abs(sprite.scale.x)
	move_and_slide(Vector2(move_dir * MOVE_SPEED, y_velo), Vector2(0, -1))
 
	var grounded = is_on_floor()
	if(is_on_ceiling()):
		y_velo = 0
	y_velo += GRAVITY
	if grounded and y_velo >= 5:
		y_velo = 5
	if y_velo > MAX_FALL_SPEED:
		y_velo = MAX_FALL_SPEED
	
	if(attacking):
		play_anim("attack")
	elif grounded:
		if move_dir == 0:
			play_anim("idle")
		else:
			play_anim("run")
	else:
		play_anim("jump")
	attacking = false
 
func play_anim(anim_name):
	if state == anim_name:
		return
	anim_player.play(anim_name)
	state = anim_name


func _on_HandHitArea_body_entered(body):
	if(body.has_method("get_hit") && state == "attack" && body.get_meta("enemy") == null):
		body.get_hit()

func get_hit():
	$HitSound.play()
	health -= 1
	if(health <= 0):
		queue_free()

func _on_WallCheck_changeway():
	way = -way

func _on_WallCheck_attack():
	attacking = true
	pass # Replace with function body.
