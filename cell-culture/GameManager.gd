extends Spatial

var grid = [[]] #list of all tile objects [column][row]
var timeBetweenRounds = 0.5
var roundSteps = 5
var currRound := 0
var isRunning = false
var spawnProtection := 11 #after how many rounds the minNeighbours rule is enforced

var livingCellsEnemy = [] #list of all enemy cells
var enemyStats = {
	startCoords = Vector2(9,1),
	minNeighbours = 1,
	maxNeighbours = 3,
	mitosisAmount = 3,
	direction = "random",
	defense = 2,
	enemy = "player"
	}

var livingCells = [] #list of all living player cells
var playerStats = {
	startCoords = Vector2(10,18),
	minNeighbours = 2,
	maxNeighbours = 3,
	mitosisAmount = 3,
	direction = "random",
	defense = 1,
	enemy = "com"
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	var petriDishCreator = get_node("../PetriDishCreator")
	yield(petriDishCreator, "ready")
	grid = petriDishCreator.columns #get grid list from creator
	
	#initialize the starting cell
	var initialCell = get_cell_from_coords(playerStats["startCoords"])
	initialCell.faction = "player"
	initialCell.come_to_live(playerStats["mitosisAmount"])
	livingCells.append(initialCell)
	
	#initialize the enemy cell
	var enemyCell = get_cell_from_coords(enemyStats["startCoords"])
	enemyCell.faction = "com"
	enemyCell.come_to_live(enemyStats["mitosisAmount"])
	livingCellsEnemy.append(enemyCell)
	
	show_cell_configuration()
	update_stats()

func _input(event):
	if event.is_action_pressed("ui_accept") && !isRunning:
		isRunning = true
		hide_cell_configuration()
		
		for i in range(roundSteps):
			currRound += 1
			#print("Round " + str(currRound) + ":")
			var tmpLivingCells = [] + livingCells
			for cell in tmpLivingCells:
				analyze_environment(cell)
			#print("nmbr of cells: ",livingCells.size())
		
			var tmpEnemyCells = [] + livingCellsEnemy
			for cell in tmpEnemyCells:
				analyze_environment(cell)
			#print("nmbr of enemy cells: ",livingCellsEnemy.size())
			
			update_stats()
			yield(get_tree().create_timer(timeBetweenRounds),"timeout")
		
		isRunning = false
		show_cell_configuration()

	if event.is_action_pressed("ui_cancel"):
		if (!isRunning):
			toggle_cell_configuration()

#abilities 
func analyze_environment(activeCell):
	#vars
	var stats
	if activeCell.faction == "player":
		stats = playerStats
	else:
		stats = enemyStats
	
	var startCoords = stats["startCoords"]
	var minNeighbours = stats["minNeighbours"]
	var maxNeighbours =  stats["maxNeighbours"]
	var mitosisAmount = stats["mitosisAmount"]
	var direction = stats["direction"]
	var defense = stats["defense"]
	var enemy = stats["enemy"]
	
	var neighbourCoords = activeCell.neighbours
	
	var inhabitableCells = []
	var livingNeighbours = []
	var enemyNeighbours = []
	
	#check neighbouring tiles for inhabitableCells, neighbours and enemies
	for neighbourCoord in neighbourCoords:
		var neighbourCell = get_cell_from_coords(neighbourCoord)
		if neighbourCell.isAlive == false and neighbourCell.isObstacle == false:
			inhabitableCells.append(neighbourCell)
		elif neighbourCell.isAlive == true && neighbourCell.faction == activeCell.faction:
			livingNeighbours.append(neighbourCell)
		if neighbourCell.faction == stats["enemy"]:
			enemyNeighbours.append(neighbourCell)
	
#	print("["+ activeCell.name + "] " + "inhabitable: "+ str(inhabitableCells.size()) + "| living neighbours: " + str(livingNeighbours.size()) + " | enemy neighbours: " + str(enemyNeighbours.size()))
	
	
	#decide whether the current cell gets overtaken by the enemy
	if enemyNeighbours.size() > defense:	
		var mitosisStatus = activeCell.cellDivisionsLeft
		kill_cell(activeCell)
		activeCell.faction = stats["enemy"]
		activeCell.come_to_live(mitosisStatus)
		if activeCell.faction == "player":
			livingCells.append(activeCell)
		else:
			livingCellsEnemy.append(activeCell)
		return
	
	#check if there are not too less and not too many neighbours
	var nmbrNeighbours = livingNeighbours.size()
	if (nmbrNeighbours <= minNeighbours && currRound >= spawnProtection):
		kill_cell(activeCell)
	elif nmbrNeighbours <= maxNeighbours and inhabitableCells.size() >= 1:
		if (activeCell.cellDivisionsLeft >= 1):
			activeCell.cellDivisionsLeft = activeCell.cellDivisionsLeft - 1
			create_new_cell(activeCell, inhabitableCells)
	elif nmbrNeighbours >= maxNeighbours:
		kill_cell(activeCell)

func create_new_cell(activeCell, inhabitableCells):
	var stats
	if activeCell.faction == "player":
		stats = enemyStats
	else:
		stats = playerStats
	
	var mitosisAmount = stats["mitosisAmount"]
	var direction = stats["direction"]
	
	var newCell
	
	randomize()
	
	#spawn the new cell in the prefered direction if available
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
	
	#if the prefered direction is random spawn on random inhabitable neighbouring cell
	elif direction == "random":
		newCell = inhabitableCells[randi() % inhabitableCells.size()]
	
	#initialize the new cell from the current factions stats
	newCell.faction = activeCell.faction
	newCell.come_to_live(stats["mitosisAmount"])
	if activeCell.faction == "player":
		livingCells.append(newCell)
	else:
		livingCellsEnemy.append(newCell)

func kill_cell(activeCell):
	activeCell.die()
	
	if activeCell.faction == "player":
		livingCells.erase(activeCell)
	else:
		livingCellsEnemy.erase(activeCell)


#helper
func get_cell_from_coords(coords:Vector2):
	var cell = grid[coords.x][coords.y]
	return cell

#ui
func update_stats():
	var playerCells = "\nPlayer Cells: " + str(livingCells.size())
	var enemyCells = "\nEnemy Cells: " + str(livingCellsEnemy.size())
	
	var newText
	newText = "\nRound: " + str(currRound) + "\n"
	if livingCells.size() >= livingCellsEnemy.size():
		newText += playerCells
		newText += enemyCells
	else:
		newText += enemyCells
		newText += playerCells
	
	
	get_node("../Interface/Stats").text = newText

func toggle_cell_configuration():
	get_node("../Interface/Configuration Menu").visible = !get_node("../Interface/Configuration Menu").visible
	if get_node("../Interface/Configuration Menu").visible == false:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_cell_configuration():
	get_node("../Interface/Configuration Menu").visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func show_cell_configuration():
	get_node("../Interface/Configuration Menu").visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
