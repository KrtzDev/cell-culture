tool
extends Spatial

var gridWidth : int = 30
var gridHeight : int = 20

var hexTile
var tileSize : float = 0.9

var columns = []

# Called when the node enters the scene tree for the first time.
func _ready():
	hexTile = preload("res://tile.tscn")
	create_grid()
 
func calc_world_pos(var grid_pos : Vector2):
	var offset := 0.0
	if int(grid_pos.y) % 2 != 0:
		offset = tileSize/2
		gridWidth -= 1
	else:
		gridWidth += 1
	var x = grid_pos.x * tileSize + offset
	var z = grid_pos.y * tileSize * cos(deg2rad(30))
	return(Vector3(x, 0, z))
 
func create_grid():
	for x in range(gridWidth):
		columns.append([])
		for y in range(gridHeight):
			var tile = hexTile.instance()
			var gridPos = Vector2(x, y)
			#configure tile
			tile.set_name(str(x) + "|" + str(y))
			tile.gridPos = gridPos
			
			add_child(tile)
			var worldPos = calc_world_pos(gridPos)
			tile.set_translation(worldPos)
			columns[x].append(tile)
