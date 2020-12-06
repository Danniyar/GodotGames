extends Spatial

const BLOCK = preload("res://prefabs/Block.tscn")
var blocks = []

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 3
	noise.period = 64
	noise.persistence = 0.5
	noise.lacunarity = 2
	for x in range(0,16):
		for z in range(0,16):
			for y in range(0,4):
				var bl = BLOCK.instance()
				add_child(bl)
				bl.set_meta("block",true)
				bl.global_transform = global_transform
				bl.global_transform.origin.x += x * 2
				bl.global_transform.origin.z += z * 2
				var perlin_value = noise.get_noise_3d(x*2,global_transform.origin.y,z*2)
				bl.global_transform.origin.y += int(2 * floor(perlin_value*16 / 2)) + y*2
				blocks.append(bl)
	pass # Replace with function body.

func newBlock(position):
	var bl = BLOCK.instance()
	add_child(bl)
	bl.set_meta("block",true)
	bl.global_transform.origin = position
	blocks.append(bl)
