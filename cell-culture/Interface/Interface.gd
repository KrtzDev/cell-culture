extends Control

onready var gameManager = get_node("../GameManager")

var directions = ["random","north","east","south","west"]

# Called when the node enters the scene tree for the first time.
func _ready():
	update_menu_text()
	update_round_stats()
	add_directions_to_dropdown()

func update_round_stats():
		#craft text for stats
	var playerCells = "\nPlayer Cells: " + str(gameManager.livingCells.size())
	var enemyCells = "\nEnemy Cells: " + str(gameManager.livingCellsEnemy.size())
	
	var newText
	newText = "Round: " + str(gameManager.currRound) + "\n"
	if gameManager.livingCells.size() >= gameManager.livingCellsEnemy.size():
		newText += playerCells
		newText += enemyCells
	else:
		newText += enemyCells
		newText += playerCells
	
	newText += "\n\nEnemy Defense: " + str(gameManager.enemyStats["defense"])
	
	$Stats.text = newText

func update_menu_text():
	var stats = gameManager.playerStats
	
	var minNeighbours = stats["minNeighbours"]
	var maxNeighbours =  stats["maxNeighbours"]
	var mitosisAmount = stats["mitosisAmount"]
	var direction = stats["direction"]
	var defense = stats["defense"]
	var spawnProtection = gameManager.spawnProtection
	var skillPoints = gameManager.skillPoints
	
	#configure menu text
	$"Configuration Menu/Panel/VBoxContainer/RichTextLabel".text = "Points to spend: " + str(skillPoints)
	
	$"Configuration Menu/Panel/VBoxContainer/minNeighbours/RichTextLabel".text = "Starting from round "+ str(spawnProtection) +", your cells need minimum " + str(minNeighbours) + " neighbours to stay alive"
	$"Configuration Menu/Panel/VBoxContainer/maxNeighbours/RichTextLabel".text = "Your cells will die if there are more than " + str(maxNeighbours) + " neighbours"
	$"Configuration Menu/Panel/VBoxContainer/mitosis/RichTextLabel".text = "Newly created cells will divide "+str(mitosisAmount)+" times before stopping"
	$"Configuration Menu/Panel/VBoxContainer/defense/RichTextLabel".text = "Your cells will be taken over by the enemy if there are more than " + str(defense) + " neighbouring enemy cells"
	
	if gameManager.currRound == 0:
		$"Configuration Menu/Panel/VBoxContainer/StartRound/StartRound_Button".text = "Start Simulation"
	else:
		$"Configuration Menu/Panel/VBoxContainer/StartRound/StartRound_Button".text = "Continue Simulation"


	#activate buttons only if not outspeced and if there are skill points to spend
	if skillPoints <= 0:
		$"Configuration Menu/Panel/VBoxContainer/minNeighbours/minNeigh_Button".disabled = true
		$"Configuration Menu/Panel/VBoxContainer/maxNeighbours/maxNeigh_Button".disabled = true
		$"Configuration Menu/Panel/VBoxContainer/mitosis/mitosis_Button".disabled = true
		$"Configuration Menu/Panel/VBoxContainer/defense/defense_Button".disabled = true
	else:
		$"Configuration Menu/Panel/VBoxContainer/minNeighbours/minNeigh_Button".disabled = false
		$"Configuration Menu/Panel/VBoxContainer/maxNeighbours/maxNeigh_Button".disabled = false
		$"Configuration Menu/Panel/VBoxContainer/mitosis/mitosis_Button".disabled = false
		$"Configuration Menu/Panel/VBoxContainer/defense/defense_Button".disabled = false
	
	if minNeighbours <= 1:
		$"Configuration Menu/Panel/VBoxContainer/minNeighbours/minNeigh_Button".disabled = true
	if maxNeighbours >= 6:
		$"Configuration Menu/Panel/VBoxContainer/maxNeighbours/maxNeigh_Button".disabled = true
	if mitosisAmount >= 1000:
		$"Configuration Menu/Panel/VBoxContainer/mitosis/mitosis_Button".disabled = true
	if defense >= 6:
		$"Configuration Menu/Panel/VBoxContainer/defense/defense_Button".disabled = true

func show_GameOverScreen(win : bool):
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var winText= "You won!"
	var loseText= "You lost!"
	
	if (win == true):
		$"GameOverScreen/Panel/RichTextLabel".text = winText
	else:
		$"GameOverScreen/Panel/RichTextLabel".text = loseText
	
	$"Configuration Menu".visible = false
	$"GameOverScreen".visible = true

#configure dropdown menu
func add_directions_to_dropdown():
	var dropdown = $"Configuration Menu/Panel/VBoxContainer/direction/OptionButton"
	for dir in directions:
		dropdown.add_item(dir)

func _on_minNeigh_Button_pressed():
	gameManager.playerStats["minNeighbours"] -= 1
	gameManager.skillPoints -= 1
	update_menu_text()

func _on_maxNeigh_Button_pressed():
	gameManager.playerStats["maxNeighbours"] += 1
	gameManager.skillPoints -= 1
	update_menu_text()

func _on_mitosis_Button_pressed():
	gameManager.playerStats["mitosisAmount"] += 5
	gameManager.skillPoints -= 1
	update_menu_text()

func _on_defense_Button_pressed():
	gameManager.playerStats["defense"] += 1
	gameManager.skillPoints -= 1
	update_menu_text()

func _on_StartRound_Button_pressed():
	gameManager.start_simulation()


func _on_Exit_Button_pressed():
	get_tree().change_scene("res://MainMenu.tscn")


func _on_OptionButton_item_selected(index):
	gameManager.playerStats["direction"] = directions[index]
