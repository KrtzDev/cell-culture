extends Spatial

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func _on_Play_Button_pressed():
	get_tree().change_scene("res://Level.tscn")

func _on_Exit_Button_pressed():
	get_tree().quit()
