extends CharacterBody2D

var speed: float = 100
var can_move: bool = true

func _physics_process(delta: float):
	pass

func player_movement(delta):
	var input_direction = Input.get_vector("left", "right", "up", "down")
	
	if input_direction.length() > 0:
		input_direction = input_direction.normalized()
	if can_move:
		velocity = input_direction * speed
	
	move_and_slide()
