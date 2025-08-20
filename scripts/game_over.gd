extends CanvasLayer

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func show_game_over():
	visible = true
	anim_player.play("fade_in")

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
