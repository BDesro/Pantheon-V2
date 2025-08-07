extends Node2D

@onready var score_label = $CanvasLayer/Control/ScoreLabel

func _ready():
	GlobalPlayerData.node_creation_parent = self

func _on_ready():
	while score_label == null:
		await get_tree().process_frame
	
	GlobalPlayerData.score_label = score_label

func _exit_tree():
	GlobalPlayerData.node_creation_parent = null
