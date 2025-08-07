extends Node

signal player_died

@onready var active: int = 1
@onready var camera: Camera2D = get_parent().get_node("Camera2D")
var health_bar: ProgressBar = null

var characters: Array[CharacterBody2D]
var active_character: CharacterBody2D = null

@onready var health: int = 0
@onready var is_alive: bool = false
var total_kills: int = 0 # Current kills by the player during this playthrough
var kills_since_last_death: int = 0
var kill_threshold: int = 5

func _ready():
	for child in get_children():
		if child is CharacterBody2D:
			characters.append(child)
			child.set_process(false) # Deactivate initially
			child.set_physics_process(false)
			child.hide()
	
	# Auto-start with first character
	if characters.size() > 0:
		set_active_character(characters[0])
	
	_setup_camera()
	GlobalPlayerData.global_player_instance = self

func _on_ready() -> void:
	health = active_character.max_health
	is_alive = true
	await _wait_for_ui()
	health_bar = GlobalPlayerData.player_health_bar
	health_bar.init_health(health)

func _wait_for_ui():
	while GlobalPlayerData.player_health_bar == null:
		await get_tree().process_frame

func set_active_character(new_character: CharacterBody2D):
	
	var current_position: Vector2 = new_character.global_position
	
	if active_character:
		current_position = active_character.global_position
		active_character.set_process(false)
		active_character.set_physics_process(false)
		# Will throw animation to ascend/descend here
		active_character.hide()
	
	active_character = new_character
	
	active_character.global_position = current_position
	active_character.set_process(true)
	active_character.set_physics_process(true)
	active_character.show()
	

func _setup_camera():
	camera.make_current()
	

func _process(_delta):
	if active_character:
		if kills_since_last_death == kill_threshold:
			self._ascend()
			pass
		
		camera.global_position = active_character.global_position

func _ascend(): # Increments the active character id to ascend to the next player tier
	
	if active != 1: # Keeps player within range of available characters (ADJUST FOR EACH NEW ONE)
		active += 1
		# Eventual logic to handle deactivating the current character and activating the next one.
		# Should also set new character's location to the previous one's before switching and
		# activating.
		# Should also increase the kill threshold for the next ascension.
	else:
		active = 1

func _set_health(value: int):
	health = clamp(value, 0, active_character.max_health)
	if health <= 0 and is_alive:
		_die()
	
	health_bar.health = health # Gotta get this connected via autoload, not active_manager

func take_damage(damage: int): # This needs to get replaced in the global info script (just testing for now)
	var new_health = health - damage
	_set_health(new_health)
	active_character.flash_anim.play("flash")

func _die():
	active_character.get_node("CollisionShape2D").set_deferred("disabled", true) # Disables collision on death
	queue_free()

func _exit_tree() -> void:
	GlobalPlayerData.global_player_instance = null
