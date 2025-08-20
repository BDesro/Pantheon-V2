extends CharacterBody2D

signal enemy_died

@onready var sprite = $AnimatedSprite2D
@onready var health_bar = $"../HealthBar"
@onready var collision_shape = $CollisionShape2D
@onready var hitbox = $Hitbox
@onready var hurtbox = $Hurtbox
@onready var cd_timer = get_parent().get_node("HurtboxCDTimer")
@onready var flash_anim = $FlashAnimation

var rng = RandomNumberGenerator.new()
var random_distance_from_player = randf_range(0, 30)
var stop_moving: bool = false
var direction = global_position.direction_to(Vector2(0,0))
var position_to_attack = Vector2(0, 0)

const max_health: int = 50
var health: int = 50
var is_alive: bool = true

var speed: float = 50
var can_move: bool = true

var player = null

func _on_ready():
	await health_bar.ready
	health_bar.init_health(health)

func _process(_delta):
	player = GlobalPlayerData.global_player_instance
	
	if stop_moving == false and is_instance_valid(player):
		_handle_animations()
		
		if global_position.distance_to(player.active_character.global_position) > 50:
			position_to_attack = Vector2(player.active_character.global_position.x + random_distance_from_player, player.active_character.global_position.y + random_distance_from_player)
		else:
			position_to_attack = player.active_character.global_position
		direction = global_position.direction_to(position_to_attack)
		velocity = direction * speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO
	
	if velocity.y >= 0:
		health_bar.global_position = global_position + Vector2(-12, -16)
	else:
		health_bar.global_position = global_position + Vector2(-12, 16)

func _handle_animations():
	if velocity != Vector2.ZERO:
		sprite.play("slither")
		rotation = direction.angle() - PI/2

func _set_health(value: int):
	health = clamp(value, 0, max_health)
	if health <= 0 and is_alive:
		_die()
	
	health_bar.health = health # Gotta get this connected via autoload, not active_manager

func take_damage(damage: int): # This needs to get replaced in the global info script (just testing for now)
	flash_anim.play("flash")
	var new_health = health - damage
	_set_health(new_health)

func _die():
	set_process(false)
	collision_shape.set_deferred("disabled", true)# Disable environmental collision
	hurtbox.set_deferred("monitoring", false) # Can no longer hurt the player
	hitbox.set_deferred("monitorable", false) # Will no longer register hits by the player
	health_bar.queue_free()
	
	sprite.play("die")
	enemy_died.emit()

func _on_animation_finished(anim_name: StringName):
	if anim_name == "die":
		queue_free()


func _on_hurtbox_area_entered(area: Area2D) -> void: # Currently Damages enemy (UPDATE TO GLOBAL FUNCTIONS WHEN READY)
	if area.is_in_group("player_hitbox") and hurtbox.monitoring:
		_process_hit(area)

func _process_hit(player_hitbox):
	# Damage the player
	hurtbox.set_deferred("monitoring", false)
	player_hitbox.owner.get_node("active_manager").take_damage(10)
	cd_timer.start()

func _on_player_died():
	stop_moving = true

func _on_hurtbox_cd_timer_timeout() -> void:
	hurtbox.set_deferred("monitoring", true)
	await get_tree().process_frame
	
	for area in hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			_process_hit(area)

func _on_change_direction_timer_timeout() -> void:
	random_distance_from_player = randf_range(0, 30)

func _on_enemy_died() -> void:
	GlobalPlayerData.increase_player_score(10)
