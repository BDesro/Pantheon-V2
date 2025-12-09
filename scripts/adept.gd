extends CharacterBody2D

# Child Nodes
@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var flash_anim = $FlashAnimation
@onready var col_shape = $CollisionShape2D
@onready var hitbox = $HitBox
@onready var sword_hitbox = $AnimatedSprite2D/Sword1Hit/CollisionPolygon2D
@onready var dash_cd_timer = $DashCDTimer
@onready var fireball_cd_timer = $FireballCDTimer

# Summons
@export var fireball: PackedScene = preload("res://scenes/fireball.tscn")

# Character Info / Stats
@export var character_id: int = 1 # Used by active_manager's "active" var to keep track of current character
@export var character_name = "Adept"
@export var max_health: int = 225
@export var health_regen_per_sec: int = 4
@export var speed: float = 125.0
@export var sword_dmg = 50

@export var dash_cd: float = 2.0
@export var fireball_cd: float = 6.0

var last_sword: StringName = "sword1"

var input_direction: Vector2

# Default Score Threshold
@export var ascension_threshold = 5000

@export var abilities = {
	0: {
		"name": "Sword Slash",
		"cooldown": 0.0,
		"image_path": "res://assets/icons/Pantheon_Adept_Sword_Icon.png",
		"mapped_key": "lmb"
		},
	1: {
		"name": "Fireball",
		"cooldown": fireball_cd,
		"image_path": "res://assets/icons/Pantheon_Adept_Fireball_Icon.png",
		"mapped_key": "rmb"
		},
	2: {
		"name": "Raise Shield",
		"cooldown": dash_cd,
		"image_path": "res://assets/icons/Pantheon_Adept_Dash_Icon.png",
		"mapped_key": "space"
	}
}

func _on_ready():
	dash_cd_timer.wait_time = dash_cd
	fireball_cd_timer.wait_time = fireball_cd

func _physics_process(delta: float):
	_player_movement(delta)

func _player_movement(_delta):
	
	if anim_player.current_animation != "dash":
		# Makes the character face the direction of the mouse on screen
		var mouse_position = get_global_mouse_position()
		var look_direction = (mouse_position - global_position).normalized()
		
		rotation = look_direction.angle() + PI / 2
		
		# Basic movement
		input_direction = Input.get_vector("left", "right", "up", "down")
		if input_direction.length() > 0:
			input_direction = input_direction.normalized()
		
		velocity = input_direction * speed
	
	_movement_animations()
	move_and_slide()
	
	if Input.is_action_just_pressed("rmb"):
		if fireball_cd_timer.is_stopped():
			anim_player.stop()
			anim_player.play("fireball")
			fireball_cd_timer.start()
	elif Input.is_action_just_pressed("space"):
		if dash_cd_timer.is_stopped():
			anim_player.stop()
			anim_player.play("dash")
			dash_cd_timer.start()
		
	elif not anim_player.is_playing():
		if Input.is_action_just_pressed("lmb"):
			anim_player.stop()
			anim_player.play("sword1")

func _movement_animations(): # Basic idling and walking coupling with movement
	if anim_player.is_playing():
		return
	
	if velocity.x != 0 or velocity.y != 0:
		sprite.play("walk")
	else:
		sprite.play("idle")

func _on_anim_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "sword1" or anim_name == "sword2" or anim_name == "dash":
		if anim_name != "dash":
			last_sword = anim_name
		
		if Input.is_action_pressed("lmb"):
			if last_sword == "sword1":
				anim_player.play("sword2")
			elif last_sword == "sword2":
				anim_player.play("sword1")

func cast_fireball():
	var fire = fireball.instantiate()
	
	var look_direction = (get_global_mouse_position() - global_position).normalized()
	fire.global_position = global_position + look_direction * 10
	fire.direction = (get_global_mouse_position() - global_position).normalized()
	get_parent().add_child.call_deferred(fire)

func _on_sword_1_hit_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		sword_hitbox.set_deferred("disabled", true)
		area.get_parent().take_damage(sword_dmg, global_position)

func _on_sword_2_hit_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		sword_hitbox.set_deferred("disabled", true)
		area.get_parent().take_damage(sword_dmg, global_position)

func _handle_dash():
	rotation = input_direction.angle() + PI / 2
	velocity = input_direction * speed * 2
