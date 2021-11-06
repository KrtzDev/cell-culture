tool
extends Spatial

var isObstacle = false
var isAlive = false
var gridPos = Vector2()
var cellDivisionsLeft
var neighbours
var faction = "neutral" #neutral, com, player


func come_to_live(mitAmount:int):
	isAlive = true
	
	if faction == "player":
		var cell = self.get_node("Cell")
		cell.visible = true
		
	elif faction == "com":
		var cell_enemy = self.get_node("Cell_enemy")
		cell_enemy.visible = true 
	
	cellDivisionsLeft=mitAmount

func die():
	isAlive = false
	self.get_node("Cell").visible = false
	self.get_node("Cell_enemy").visible = false

func get_neighbours():
	var topLeft
	var topRight
	var midLeft
	var midRight
	var botLeft
	var botRight

	if (int(gridPos.y) % 2 == 0):
		#neighbours for even row
		topLeft = Vector2(gridPos.x-1,gridPos.y-1)
		topRight = Vector2(gridPos.x,gridPos.y-1)
		
		midLeft = Vector2(gridPos.x -1,gridPos.y)
		midRight = Vector2(gridPos.x +1,gridPos.y)

		botLeft = Vector2(gridPos.x-1,gridPos.y+1)
		botRight = Vector2(gridPos.x,gridPos.y+1)
	
	else:
		#neighbours for odd row
		topLeft = Vector2(gridPos.x,gridPos.y-1)
		topRight = Vector2(gridPos.x+1,gridPos.y-1)
		
		midLeft = Vector2(gridPos.x -1,gridPos.y)
		midRight = Vector2(gridPos.x +1,gridPos.y)

		botLeft = Vector2(gridPos.x,gridPos.y+1)
		botRight = Vector2(gridPos.x+1,gridPos.y+1)

	var list = []
	list.append(topLeft)
	list.append(topRight)
	list.append(midLeft)
	list.append(midRight)
	list.append(botLeft)
	list.append(botRight)
	
	neighbours = list
