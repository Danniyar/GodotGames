extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const ENEMYPISTOL = preload("res://prefabs(?)/EnemyPistol.tscn")
const ENEMYKNIFE = preload("res://prefabs(?)/EnemyKnife.tscn")
const ENEMYAUTOGUN = preload("res://prefabs(?)/EnemyAutoGun.tscn")
var curEnemyPistol = null
var curEnemyKnife = null
var curEnemyAutoGun = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if(curEnemyPistol == null):
		var new_enemy = ENEMYPISTOL.instance()
		get_parent().add_child(new_enemy)
		curEnemyPistol = new_enemy
	if(curEnemyKnife == null):
		var new_enemy = ENEMYKNIFE.instance()
		get_parent().add_child(new_enemy)
		curEnemyKnife = new_enemy
	if(curEnemyAutoGun == null):
		var new_enemy = ENEMYAUTOGUN.instance()
		get_parent().add_child(new_enemy)
		curEnemyAutoGun = new_enemy
