extends Node2D
class_name World

signal pause_pressed

@onready var score_label = $GameUI/Control/ScoreLabel
@onready var wave_label = $GameUI/Control/WaveLabel
@onready var game_over_scr = $GameOver

var ui_ready: bool = false

func _ready():
	GlobalData.node_creation_parent = self

func _on_ready():
	while not is_ui_ready():
		await get_tree().process_frame
	
	GlobalData.score_label = score_label
	GlobalData.wave_label = wave_label

func is_ui_ready():
	var is_ready = false
	if score_label and wave_label:
		is_ready = true
	return is_ready

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$GameUI.hide()
		pause_pressed.emit()

func game_over():
	$GameUI.hide()
	game_over_scr.show_game_over()

func _exit_tree():
	GlobalData.node_creation_parent = null


func _on_pause_menu_resumed() -> void:
	$GameUI.show()
