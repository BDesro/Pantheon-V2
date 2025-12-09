extends Node

signal player_died
signal player_state_changed

@onready var health_regen_timer: Timer = $"../HealthRegenTimer"
@onready var time_before_regen: Timer = $"../TimeBeforeRegen"
@onready var ascension_player: AnimationPlayer = $AscensionPlayer

@onready var active: int = 0
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
			child.col_shape.set_deferred("disabled", true)
			child.hitbox.set_deferred("monitorable", false)
			child.set_process(false) # Deactivate initially
			child.set_physics_process(false)
			child.hide()
	
	# Auto-start with first character
	if characters.size() > 0:
		set_active_character(characters[active])
	
	_setup_camera()
	GlobalData.global_player_instance = self

func _on_ready() -> void:
	health = active_character.max_health
	is_alive = true
	await _wait_for_ui()
	health_bar = GlobalData.player_health_bar
	health_bar.init_health(health)

func _wait_for_ui():
	while GlobalData.player_health_bar == null:
		await get_tree().process_frame

func set_active_character(new_character: CharacterBody2D):
	
	var current_position: Vector2 = new_character.global_position
	
	if active_character:
		current_position = active_character.global_position
		active_character.set_process(false)
		active_character.set_physics_process(false)
		# Will throw animation to ascend/descend here
		active_character.hide()
		active_character.col_shape.set_deferred("disabled", true)
		active_character.hitbox.set_deferred("monitorable", false)
	
	active_character = new_character
	active = active_character.character_id
	health = active_character.max_health
	
	await _on_ready()
	health_bar.init_health(health)
	
	active_character.global_position = current_position
	active_character.set_process(true)
	active_character.set_physics_process(true)
	active_character.col_shape.set_deferred("disabled", false)
	active_character.hitbox.set_deferred("monitorable", true)
	active_character.show()
	
	GlobalData.set_character_info(active)

func _setup_camera():
	camera.make_current()
	

func _process(_delta):
	camera.global_position = active_character.global_position
	$AscensionMagic.global_position = active_character.global_position

func ascend(): # Increments the active character id to ascend to the next player tier
	player_state_changed.emit()
	active += 1
	set_active_character(characters[active])

func descend():
	player_state_changed.emit()
	active -= 1
	
	var cur_score = GlobalData.player_score
	GlobalData.characters[active]["threshold"] = cur_score + characters[active].ascension_threshold
	set_active_character(characters[active])


func _set_health(value: int):
	health = clamp(value, 0, active_character.max_health)
	if health <= 0 and is_alive:
		if active == 0:
			_die()
		else:
			descend()
			return
	
	health_bar.health = health # Gotta get this connected via autoload, not active_manager

func take_damage(damage: int): # This needs to get replaced in the global info script (just testing for now)
	active_character.flash_anim.play("flash")
	var new_health = health - damage
	_set_health(new_health)
	
	health_regen_timer.one_shot = true
	health_regen_timer.stop()
	time_before_regen.start()

func heal(amount: int):
	var new_health = health + amount
	_set_health(new_health)

func _die():
	active_character.get_node("CollisionShape2D").set_deferred("disabled", true) # Disables collision on death
	player_died.emit()
	GlobalData.node_creation_parent.game_over()
	queue_free()

func _exit_tree() -> void:
	GlobalData.global_player_instance = null

func _on_health_regen_timer_timeout() -> void:
	if 0 < health and health < active_character.max_health:
		heal(ceil(active_character.health_regen_per_sec))
	else:
		health_regen_timer.stop()
		health_regen_timer.one_shot = true

func _on_time_before_regen_timeout() -> void:
	health_regen_timer.one_shot = false
	health_regen_timer.start()


func _on_ascension_animation_finished() -> void:
	$AscensionMagic.hide()
