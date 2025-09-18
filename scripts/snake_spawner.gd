extends Node2D

@export var snake: PackedScene = preload("res://scenes/enemy_snake.tscn")

func spawn_enemy():
	var enemy = snake.instantiate()
	enemy.global_position = global_position
	get_parent().add_child.call_deferred(enemy)
	return enemy
