extends CharacterBody2D

@onready var active_manager = get_parent() # Gets access to parent controller to access its globals (active, etc.)
@onready var anim_player = $AnimationPlayer
@onready var flash_anim = $FlashAnimation
@onready var spear_hitbox = $AnimatedSprite2D/SpearHit/CollisionShape2D
@onready var is_active: bool = false

@export var character_id: int = 1 # Used by active_manager's "active" var to keep track of current character
@export var character_name = "Soldier"

var max_health: int = 100
var speed: float = 100
var can_move: bool = true

# Damage Variables
var spear_thrust_dmg: int = 30

func _physics_process(delta: float):
	
	var is_active = active_manager.active
	
	if is_active == character_id: # Makes sure this character is the active one before processing behavior
		_player_movement(delta)
	else:
		pass

func _player_movement(_delta):
	
	# Makes the character face the direction of the mouse on screen
	var mouse_position = get_global_mouse_position()
	var look_direction = (mouse_position - global_position).normalized()
	
	rotation = look_direction.angle() + PI / 2
	
	#if anim_player.is_playing() == false:
		#can_move = true
	
	# Basic movement
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	
	velocity = input_direction * speed
	
	_movement_animations()
	move_and_slide()
	
	if Input.is_action_just_pressed("left_click"):
		can_move = false
		
		anim_player.play("spear_strike")
	

func _movement_animations(): # Basic idling and walking coupling with movement
	if anim_player.is_playing():
		return
	
	if velocity.x != 0 or velocity.y != 0:
		$AnimatedSprite2D.play("walk")
	else:
		$AnimatedSprite2D.play("idle")


func _on_spear_hit_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		spear_hitbox.set_deferred("disabled", true)
		area.get_parent().take_damage(spear_thrust_dmg)
