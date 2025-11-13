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
var popup: PackedScene = preload("res://scenes/score_popup.tscn")

var rng = RandomNumberGenerator.new()
var random_distance_from_player = randf_range(0, 30)
@export var stop_moving: bool = true
var direction = global_position.direction_to(Vector2(0,0))
var position_to_attack = Vector2(0, 0)

const max_health: int = 50
var health: int
var is_alive: bool = true

@export var speed: float = 50
var knockback_velocity: Vector2 = Vector2.ZERO
var knockback_decay: float = 100.0 # How quickly the knockback slows
var last_hit_source: Vector2

var player = null
var previous_player_distance = 0
var strike_distance = 40
var strike_speed = 5

func _on_ready():
	health = max_health
	speed = 50
	stop_moving = false
	while not health_bar.ready:
		get_tree().process_frame
	health_bar.init_health(health)
	
	if GlobalData.global_player_instance:
		GlobalData.global_player_instance.connect("player_descended", Callable(self, "apply_descension_knockback"))

func _process(delta):
	player = GlobalData.global_player_instance
	
	_handle_knockback(delta)
	
	if stop_moving == false and is_instance_valid(player):
		var distance_from_player = global_position.distance_to(player.active_character.global_position)
		
		_handle_animations()
		
		if distance_from_player >= 100:
			position_to_attack = Vector2(player.active_character.global_position.x + random_distance_from_player, player.active_character.global_position.y + random_distance_from_player)
		elif distance_from_player < strike_distance and previous_player_distance > strike_distance:
			if round(randf_range(0, 1)) == 1:
				stop_moving = true
				$AnimationPlayer.speed_scale += (strike_speed * 0.20)
				$AnimationPlayer.play("strike")
				velocity = Vector2.ZERO
			else:
				position_to_attack = player.active_character.global_position
		else:
			position_to_attack = player.active_character.global_position
		
		if not stop_moving:
			direction = global_position.direction_to(position_to_attack)
			velocity = direction * speed
			
		previous_player_distance = distance_from_player
	elif $AnimationPlayer.current_animation == "strike":
		pass
	else:
		velocity = Vector2.ZERO
	
	move_and_collide(velocity * delta)
	
	if velocity.y >= 0:
		health_bar.global_position = global_position + Vector2(-12, -16)
	else:
		health_bar.global_position = global_position + Vector2(-12, 16)

func _handle_animations():
	if velocity != Vector2.ZERO:
		sprite.play("slither")
		_handle_rotation()

func _handle_rotation():
	rotation = direction.angle() - PI/2

func _handle_knockback(delta: float): # Decays knockback speed each frame
	if knockback_velocity.length() > 10.0:
		var motion = knockback_velocity * delta
		move_and_collide(motion)
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_decay * delta)

func _handle_strike_lunge():
	direction = global_position.direction_to(player.active_character.global_position)
	_handle_rotation()
	velocity = direction * speed * strike_speed

func _set_health(value: int):
	health = clamp(value, 0, max_health)
	if health <= 0 and is_alive:
		hitbox.set_deferred("monitorable", false)
		_die()
	
	health_bar.health = health # Gotta get this connected via autoload, not active_manager

func take_damage(damage: int, source_position: Vector2): # This needs to get replaced in the global info script (just testing for now)
	if health > 0:
		last_hit_source = source_position
		flash_anim.play("flash")
		$AnimationPlayer.stop()
		stop_moving = false
		var new_health = health - damage
		_set_health(new_health)
	

func apply_knockback(strength: float = 5000): # Registers a knockback from a hit
	var knockback_direction = (global_position - last_hit_source).normalized()
	knockback_velocity = knockback_direction * strength

func apply_descension_knockback(): # Registers a knockback from a hit
	var strength = 200
	var knockback_direction = (global_position - GlobalData.global_player_instance.active_character.global_position).normalized()
	knockback_velocity = knockback_direction * strength

func _die():
	var score_popup = popup.instantiate()
	score_popup.global_position = global_position
	GlobalData.node_creation_parent.add_child(score_popup)
	
	$AnimationPlayer.play("die")
	enemy_died.emit()

func _on_animation_finished(anim_name: StringName):
	if anim_name == "die":
		get_parent().queue_free()
	elif anim_name == "strike":
		stop_moving = false
		$AnimationPlayer.speed_scale = 1

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
