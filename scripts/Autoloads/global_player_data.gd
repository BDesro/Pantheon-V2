extends Node

var node_creation_parent: World = null
var global_player_instance = null
var unit_name_label: Label = null
var player_health_bar: ProgressBar = null
var score_label: Label = null

var cur_character_id: int = 1
var unit_name = "Soldier"
var player_health: int = 100
var player_score: int = 0 # This will increment for each elim and stay through ascensions
var elim_threshold: int = 0 # Number of elims needed for the player to ascend
var elim_progress: int = 0 # Number of elims toward the next ascension, resets on ascension/descension

var characters = {
	1: {
		"name": "Soldier",
		"max_health": 150,
		"threshold": 5
	}
}

func set_character_info(char_id: int):
	if characters[char_id] and char_id != cur_character_id:
		cur_character_id = char_id
		unit_name = characters[char_id]["name"]
		unit_name_label.text = unit_name
		player_health = characters[char_id]["max_health"]
		elim_threshold = characters[char_id]["threshold"]
		elim_progress = 0

func increase_player_score(amount: int):
	if global_player_instance:
		player_score += amount
		elim_progress += amount
		
		score_label.text = "Score: " + str(player_score)
