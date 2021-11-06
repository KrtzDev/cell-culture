extends Spatial

var grid = [[]] #list of all tile objects [column][row]
var livingCells = [] #list of all living cells

var startCoords = Vector2(9,9)
var maxNeigbours = 4


# Called when the node enters the scene tree for the first time.
func _ready():
	var petriDishCreator = get_node("../PetriDishCreator")
	yield(petriDishCreator, "ready")
	grid = petriDishCreator.columns #get grid list from creator
	
	#initialize the starting cell
	var initialCell = get_cell_from_coords(startCoords)
	initialCell.come_to_live()
	livingCells.append(initialCell)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		var tmpLivingCells = [] + livingCells
		for cell in tmpLivingCells:
			analyze_environment(cell)

#abilanalyze_environment activeCell  
func analyze_environment(activeCell):
	var neighbourCoords = activeCell.get_neighbours()
	
	var deadNeighbours = []
	for neighbourCoord in neighbourCoords:
		var neighbourCell = get_cell_from_coords(neighbourCoord)
		if neighbourCell.isAlive == false:
			deadNeighbours.append(neighbourCell)
			
	if deadNeighbours.size() > 6-maxNeigbours:
		create_new_cell(deadNeighbours)
	else:
		activeCell.die()

func create_new_cell(deadNeighbours):
	randomize()
	var newCell = deadNeighbours[randi() % deadNeighbours.size()]
	newCell.come_to_live()
	livingCells.append(newCell)


#helper
func get_cell_from_coords(coords:Vector2):
	var cell = grid[coords.x][coords.y]
	return cell
