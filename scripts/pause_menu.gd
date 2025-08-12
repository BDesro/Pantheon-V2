extends CanvasLayer

signal resumed

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		resumed.emit()
		hide()
		get_tree().paused = false


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	show()


func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false


func _on_quit_to_main_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_exit_game_pressed() -> void:
	get_tree().quit()
