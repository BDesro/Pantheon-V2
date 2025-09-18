extends CharacterBody2D
class_name EnemySnake

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
@export var stop_moving: bool = true
var direction = global_position.direction_to(Vector2(0,0))
var position_to_attack = Vector2(0, 0)

const max_health: int = 50
var health: int = 50
var is_alive: bool = true

var speed: float = 50
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 100.0 # How quickly the knockback slows
var last_hit_source: Vector2

var player = null

func _on_ready():
	stop_moving = false
	while not health_bar.ready:
		get_tree().process_frame
	health_bar.init_health(health)

func _process(delta):
	player = GlobalData.global_player_instance
	
	_handle_knockback(delta)
	
	if stop_moving == false and is_instance_valid(player):
		_handle_animations()
		
		if global_position.distance_to(player.active_character.global_position) > 50:
			position_to_attack = Vector2(player.active_character.global_position.x + random_distance_from_player, player.active_character.global_position.y + random_distance_from_player)
		else:
			position_to_attack = player.active_character.global_position
		direction = global_position.direction_to(position_to_attack)
		velocity = direction * speed
		
		move_and_collide(velocity * delta)
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

func _handle_knockback(delta: float): # Decays knockback speed each frame
	if knockback_velocity.length() > 10.0:
		var motion = knockback_velocity * delta
		move_and_collide(motion)
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)

func _set_health(value: int):
	health = clamp(value, 0, max_health)
	if health <= 0 and is_alive:
		_die()
	
	health_bar.health = health # Gotta get this connected via autoload, not active_manager

func take_damage(damage: int, source_position: Vector2): # This needs to get replaced in the global info script (just testing for now)
	last_hit_source = source_position
	flash_anim.play("flash")
	var new_health = health - damage
	_set_health(new_health)
	

func apply_knockback(strength: float = 5000): # Registers a knockback from a hit
	var knockback_direction = (global_position - last_hit_source).normalized()
	knockback_velocity = knockback_direction * strength

func _die():
	#set_process(false)
	#collision_shape.set_deferred("disabled", true)# Disable environmental collision
	#hurtbox.set_deferred("monitoring", false) # Can no longer hurt the player
	#hitbox.set_deferred("monitorable", false) # Will no longer register hits by the player
	#health_bar.queue_free()
	#
	#sprite.play("die")
	$AnimationPlayer.play("die")
	enemy_died.emit()

func _on_animation_finished(anim_name: StringName):
	if anim_name == "die":
		get_parent().queue_free()

func _on_hurtbox_area_entered(area: Area2D) -> void: # Currently Damages enemy (UPDATE TO GLOBAL FUNCTIONS WHEN READY)
	if hurtbox.monitoring:
		if area.is_in_group("player_hitbox"):
			_process_player_hit(area)
		elif area.is_in_group("soldier_shield_hitbox"):
			_process_shield_hit(area)

func _process_player_hit(player_hitbox):
	# Damage the player
	hurtbox.set_deferred("monitoring", false)
	player_hitbox.owner.get_node("active_manager").take_damage(10)
	cd_timer.start()

func _process_shield_hit(shield_hitbox):
	pass

func _on_player_died():
	stop_moving = true

func _on_hurtbox_cd_timer_timeout() -> void:
	hurtbox.set_deferred("monitoring", true)
	await get_tree().process_frame
	
	for area in hurtbox.get_overlapping_areas():
		if area.is_in_group("player_hitbox"):
			_process_player_hit(area)
		elif area.is_in_group("soldier_shield_hitbox"):
			_process_shield_hit(area)

func _on_change_direction_timer_timeout() -> void:
	random_distance_from_player = randf_range(0, 30)

func _on_enemy_died() -> void:
	GlobalData.increase_player_score(10)
