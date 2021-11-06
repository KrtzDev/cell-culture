extends Spatial

var grid = [[]] #list of all tile objects [column][row]

var livingCells = [] #list of all living player cells

var startCoords = Vector2(7,8)
var minNeighbours = 1
var maxNeigbours = 3
var mitosisAmount = 4
var direction = "random"


# Called when the node enters the scene tree for the first time.
func _ready():
	var petriDishCreator = get_node("../PetriDishCreator")
	yield(petriDishCreator, "ready")
	grid = petriDishCreator.columns #get grid list from creator
	
	#initialize the starting cell
	var initialCell = get_cell_from_coords(startCoords)
	initialCell.come_to_live(mitosisAmount)
	livingCells.append(initialCell)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var tmpLivingCells = [] + livingCells
		for cell in tmpLivingCells:
			analyze_environment(cell)
		print("nmbr of cells: ",livingCells.size())
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


#abilities 
func analyze_environment(activeCell):
	var neighbourCoords = activeCell.neighbours
	
	var inhabitableCells = []
	var livingNeighbours = []
	
	for neighbourCoord in neighbourCoords:
		var neighbourCell = get_cell_from_coords(neighbourCoord)
		if neighbourCell.isAlive == false and neighbourCell.isObstacle == false:
			inhabitableCells.append(neighbourCell)
		elif neighbourCell.isAlive == true:
			livingNeighbours.append(neighbourCell)
	
	var nmbrNeighbours = livingNeighbours.size()		
	if (nmbrNeighbours <= minNeighbours && livingCells.size()>minNeighbours*2):
		kill_cell(activeCell)
	elif nmbrNeighbours <= maxNeigbours and inhabitableCells.size() >= 1:
		if (activeCell.cellDivisionsLeft >= 1):
			activeCell.cellDivisionsLeft = activeCell.cellDivisionsLeft - 1
			create_new_cell(activeCell, inhabitableCells)
	elif nmbrNeighbours >= maxNeigbours:
		kill_cell(activeCell)

func create_new_cell(activeCell, inhabitableCells):
	
	var newCell
	
	randomize()
	
	if direction != "random":
		var gridPos = activeCell.gridPos
		
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
		
		if direction == "east":
			if (get_cell_from_coords(midRight) in inhabitableCells):
				newCell=get_cell_from_coords(midRight)
			elif ((get_cell_from_coords(topRight) in inhabitableCells) and (get_cell_from_coords(botRight) in inhabitableCells)):
				var topBot = [topRight,botRight]
				newCell=get_cell_from_coords(topBot[randi() % 2])
			elif (get_cell_from_coords(topRight) in inhabitableCells):
				newCell=get_cell_from_coords(topRight)
			elif (get_cell_from_coords(botRight) in inhabitableCells):
				newCell=get_cell_from_coords(botRight)
			else:
				newCell = inhabitableCells[randi() % inhabitableCells.size()]
					
		elif direction == "west":
			if (get_cell_from_coords(midLeft) in inhabitableCells):
				newCell=get_cell_from_coords(midLeft)
			elif ((get_cell_from_coords(topLeft) in inhabitableCells) and (get_cell_from_coords(botLeft) in inhabitableCells)):
				var topBot = [topLeft,botLeft]
				newCell=get_cell_from_coords(topBot[randi() % 2])
			elif ((get_cell_from_coords(topLeft) in inhabitableCells)):
				newCell=get_cell_from_coords(topLeft)
			elif ((get_cell_from_coords(botLeft) in inhabitableCells)):
				newCell=get_cell_from_coords(botLeft)
			else:
				newCell = inhabitableCells[randi() % inhabitableCells.size()]
				
		elif direction == "north":
			if ((get_cell_from_coords(topRight) in inhabitableCells) and (get_cell_from_coords(topLeft) in inhabitableCells)):
				var rightLeft = [topRight,topLeft]
				newCell=get_cell_from_coords(rightLeft[randi() % 2])
			elif (get_cell_from_coords(topRight) in inhabitableCells):
				newCell=get_cell_from_coords(topRight)
			elif ((get_cell_from_coords(topLeft) in inhabitableCells)):
				newCell=get_cell_from_coords(topLeft)
			else:
				newCell = inhabitableCells[randi() % inhabitableCells.size()]
				
		elif direction == "south":
			if ((get_cell_from_coords(botRight) in inhabitableCells) and (get_cell_from_coords(botLeft) in inhabitableCells)):
				var rightLeft = [botRight,botLeft]
				newCell=get_cell_from_coords(rightLeft[randi() % 2])
			elif (get_cell_from_coords(botLeft) in inhabitableCells):
				newCell=get_cell_from_coords(botLeft)
			elif ((get_cell_from_coords(botRight) in inhabitableCells)):
				newCell=get_cell_from_coords(botRight)
			else:
				newCell = inhabitableCells[randi() % inhabitableCells.size()]
			
	elif direction == "random":
		newCell = inhabitableCells[randi() % inhabitableCells.size()]
		
		
	newCell.come_to_live(mitosisAmount)
	livingCells.append(newCell)

func kill_cell(activeCell):
	activeCell.die()
	livingCells.erase(activeCell)


#helper
func get_cell_from_coords(coords:Vector2):

	var cell = grid[coords.x][coords.y]
	return cell
