extends Control

var gameManager

# Called when the node enters the scene tree for the first time.
func _ready():
	gameManager = get_node("../GameManager")
	updateText()

func updateText():
	var stats = gameManager.playerStats
	
	var minNeighbours = stats["minNeighbours"]
	var maxNeighbours =  stats["maxNeighbours"]
	var mitosisAmount = stats["mitosisAmount"]
	var direction = stats["direction"]
	var defense = stats["defense"]
	var spawnProtection = gameManager.spawnProtection
	
	$"Configuration Menu/Panel/VBoxContainer/minNeighbours/RichTextLabel".text = "Starting from round "+ str(spawnProtection) +", cells needs minimum " + str(minNeighbours) + " neighbours to stay alive"
	$"Configuration Menu/Panel/VBoxContainer/maxNeighbours/RichTextLabel".text = "Your cells will die if there are more than " + str(maxNeighbours) + " neighbours"
	$"Configuration Menu/Panel/VBoxContainer/mitosis/RichTextLabel".text = "Newly created cells will divide "+str(mitosisAmount)+" times before stopping"
	$"Configuration Menu/Panel/VBoxContainer/defense/RichTextLabel".text = "Your cells will be taken over by the enemy if there are more than " + str(defense) + " neighbouring enemy cells"


func _on_minNeigh_Button_pressed():
	gameManager.playerStats["minNeighbours"] -= 1
	updateText()

func _on_maxNeigh_Button_pressed():
	gameManager.playerStats["maxNeighbours"] += 1
	updateText()

func _on_mitosis_Button_pressed():
	gameManager.playerStats["mitosisAmount"] += 5
	updateText()

func _on_defense_Button_pressed():
	gameManager.playerStats["defense"] += 1
	updateText()
