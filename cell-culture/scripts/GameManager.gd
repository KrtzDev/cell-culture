extends Spatial

onready var interface = get_node("../Interface")

var timeBetweenRounds = 0.75 #delay in seconds between each simulated round
var roundSteps = 5 #how many rounds are simulated before returning to configuration menu
var spawnProtection := 11 #after how many rounds the minNeighbours rule is enforced
var enemyAggro = 5 # from 0-10 set how aggressive the enemy is

var grid = [[]] #list of all tile objects [column][row]
var currRound = 0 #how many rounds elapsed
var skillPoints = 0
var isRunning = false #is the simulation running


var livingCellsEnemy = [] #list of all enemy cells
var enemyStats = {
	startCoords = Vector2(9,1),
	minNeighbours = 1,
	maxNeighbours = 2,
	mitosisAmount = 3,
	direction = "random",
	attack = 2,
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
	attack = 1,
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

func _input(event):
	if (!isRunning):
		if (event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel")):
			toggle_cell_configuration()

func start_simulation():
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
		
		interface.update_round_stats()
		
		if check_game_over():
			return
			
		yield(get_tree().create_timer(timeBetweenRounds),"timeout")
	
	isRunning = false
	skillPoints += 1
	improve_enemy()
	
	#show menu
	interface.update_menu_text()
	show_cell_configuration()

func check_game_over():
	var gameOver = true
	
	if livingCells.size() == 0:
		isRunning = true
		interface.show_GameOverScreen(false)
	elif livingCellsEnemy.size() == 0:
		isRunning = true
		interface.show_GameOverScreen(true)
	else:
		gameOver = false
	
	return gameOver

func improve_enemy():
	#improve random stat
	var imprStats = ["attack", "defense", "maxNeighbours", "mitosisAmount"]
	var stat = imprStats[randi() % imprStats.size()]
	
	print ("Enemy is improving " + stat + " to " + str(enemyStats[stat]+1))
	enemyStats[stat] += 1
	
	#cap defense at 6
	if enemyStats["defense"] >= 7:
		enemyStats["defense"] = 6
	
	#cap attack at 5
	if enemyStats["attack"] >= 6:
		enemyStats["attack"] = 5
	
	#cap maxNeighbours at 6
	if enemyStats["maxNeighbours"] >= 7:
		enemyStats["maxNeighbours"] = 6
	
	#attack player if early round and defense is lower or equal to own defense
	enemyStats["direction"] = "random"
	
	if enemyStats["defense"]>=playerStats["defense"]:
		randomize()
		if (randi()%10+1) <= enemyAggro:
			enemyStats["direction"] = "south"
			print("Enemy decides to attack!")


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
	var factionNeighbours = []
	
	#check neighbouring tiles for inhabitableCells, neighbours and enemies
	for neighbourCoord in neighbourCoords:
		var neighbourCell = get_cell_from_coords(neighbourCoord)
		if neighbourCell.isAlive == false and neighbourCell.isObstacle == false:
			inhabitableCells.append(neighbourCell)
		if neighbourCell.isAlive == true:
			livingNeighbours.append(neighbourCell)
		if neighbourCell.faction == stats["enemy"]:
			enemyNeighbours.append(neighbourCell)
		elif neighbourCell.faction == activeCell.faction:
			factionNeighbours.append(neighbourCell)
	
#	print("["+ activeCell.name + "] " + "inhabitable: "+ str(inhabitableCells.size()) + "| living neighbours: " + str(livingNeighbours.size()) + " | enemy neighbours: " + str(enemyNeighbours.size()))
	
	#decide whether the current cell gets overtaken by the enemy
	var enemyNeighbourAttack
	if (stats == playerStats):
		enemyNeighbourAttack=enemyStats["attack"]
	else:
		enemyNeighbourAttack=playerStats["attack"]
	
	if ((enemyNeighbours.size()*enemyNeighbourAttack*0.5) > (defense*2)):
		print("cell gets overtaken by " + stats["enemy"])
		var mitosisStatus = activeCell.cellDivisionsLeft
		kill_cell(activeCell)
		activeCell.faction = stats["enemy"]
		activeCell.come_to_live(mitosisStatus)
		if activeCell.faction == "player":
			livingCells.append(activeCell)
		else:
			livingCellsEnemy.append(activeCell)
		return
	
	#check if there are too many neighbours
	var nmbrNeighbours = livingNeighbours.size()
	if nmbrNeighbours >= maxNeighbours:
		kill_cell(activeCell)
	elif nmbrNeighbours <= maxNeighbours and inhabitableCells.size() >= 1:
		if (activeCell.cellDivisionsLeft >= 1):
			activeCell.cellDivisionsLeft = activeCell.cellDivisionsLeft - 1
			create_new_cell(activeCell, inhabitableCells)
	
	#check if there are enough friendly neighbours to continue
	if (factionNeighbours.size() <= minNeighbours && currRound >= spawnProtection):
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
				inhabitableCells.append(get_cell_from_coords(midRight))
			elif (get_cell_from_coords(topRight) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(topRight))
			elif (get_cell_from_coords(botRight) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(botRight))
					
		elif direction == "west":
			if (get_cell_from_coords(midLeft) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(midLeft))
			elif (get_cell_from_coords(topLeft) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(topLeft))
			elif (get_cell_from_coords(botLeft) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(botLeft))
				
		elif direction == "north":
			if (get_cell_from_coords(topLeft) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(topLeft))
			elif (get_cell_from_coords(topRight) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(topRight))
				
		elif direction == "south":
			if (get_cell_from_coords(botLeft) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(botLeft))
			elif (get_cell_from_coords(botRight) in inhabitableCells):
				inhabitableCells.append(get_cell_from_coords(botRight))
		
		#select random from list with additional entries for preferred direction
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
