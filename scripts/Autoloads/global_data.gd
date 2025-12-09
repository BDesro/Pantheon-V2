extends Node

var node_creation_parent: World = null
var global_player_instance = null
var global_wave_spawner = null

var unit_name_label: Label = null
var player_health_bar: ProgressBar = null
var score_label: Label = null
var wave_label: Label = null
var num_enemies_label: Label = null
var ability_hotbar: Control = null

var cur_character_id: int = 1
var unit_name = "Soldier"
var player_health: int = 100
var player_score: int = 0 # This will increment for each elim and stay through ascensions
var score_threshold: int = 0 # Number of elims needed for the player to ascend
var elim_progress: int = 0 # Number of elims toward the next ascension, resets on ascension/descension

var characters = {
	0: {
		"name": "Soldier",
		"max_health": 100,
		"threshold": 450
	},
	1: {
		"name": "Adept",
		"max_health": 225,
		"threshold": 10000
	}
}

func set_character_info(char_id: int):
	if characters[char_id] and char_id != cur_character_id:
		cur_character_id = char_id
		unit_name = characters[char_id]["name"]
		unit_name_label.text = unit_name
		player_health = characters[char_id]["max_health"]
		score_threshold = characters[char_id]["threshold"]
		elim_progress = 0
		
		if ability_hotbar:
			ability_hotbar.populate_abilities(global_player_instance.active_character)

func increase_player_score(amount: int):
	if global_player_instance:
		player_score += amount
		elim_progress += amount
		
		if player_score >= score_threshold and characters.has(cur_character_id + 1):
			global_player_instance.ascension_player.play("ascension")
		
		score_label.text = "Score: " + str(player_score)
