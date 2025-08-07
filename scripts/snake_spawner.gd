# Spawns a new snake every 3.5 seconds from the placed position
extends Node2D

@onready var snake = preload("res://scenes/enemy_snake.tscn")


func _on_timer_timeout() -> void:
	var enemy = snake.instantiate()
	enemy.global_position = global_position
	get_parent().add_child(enemy)
