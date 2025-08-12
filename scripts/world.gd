extends Node2D

signal pause_pressed

@onready var score_label = $GameUI/Control/ScoreLabel

func _ready():
	GlobalPlayerData.node_creation_parent = self
	

func _on_ready():
	while score_label == null:
		await get_tree().process_frame
	
	GlobalPlayerData.score_label = score_label

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		$GameUI.hide()
		pause_pressed.emit()

func _exit_tree():
	GlobalPlayerData.node_creation_parent = null


func _on_pause_menu_resumed() -> void:
	$GameUI.show()
