extends Spatial

export var gridWidth : int = 5
export var gridHeight : int = 5

var hexTile
var tileWidth : float = 1
var tileHeight : float = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	hexTile = preload("res://tile.tscn")
	create_grid()
 
func calc_world_pos(var grid_pos : Vector2):
	var offset = 0.0
	if int(grid_pos.y) % 2 != 0:
		offset = tileWidth/2
		gridWidth -= 1
	else:
		gridWidth += 1
	var x = grid_pos.x * tileWidth + offset
	var z = grid_pos.y * tileHeight * 0.75
	return(Vector3(x, 0, z))
 
func create_grid():
	for x in range(gridWidth):
		for y in range(gridHeight):
			var tile = hexTile.instance()
			var grid_pos = Vector2(x, y)
			tile.set_name(str(x) + "|" + str(y))
			add_child(tile)
			var world_pos = calc_world_pos(grid_pos)
			tile.set_translation(world_pos)

