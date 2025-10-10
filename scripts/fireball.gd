extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var anim_player = $AnimationPlayer
@onready var hitbox = $HitBox/HitBoxArea

@export var speed: float = 150
@export var damage: int = 100
var direction: Vector2
	
func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_hit_box_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemies"):
		$ExplosionTimer.paused = true
		area.get_parent().take_damage(damage, global_position)
		
		if anim_player.current_animation == "fly":
			velocity = Vector2.ZERO
			anim_player.play("explode")
		
		

func _on_child_entered_tree(node: Node) -> void:
	velocity = direction * speed
	rotation = direction.angle() + PI / 2
	
func _on_explosion_timer_timeout() -> void:
	anim_player.stop()
	velocity = Vector2.ZERO
	anim_player.play("explode")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "explode":
		queue_free()
