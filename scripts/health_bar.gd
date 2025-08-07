extends ProgressBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health: int = 0 : set = _set_health

func _set_health(new_health: int):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	#if health <= 0:
		#queue_free()
	
	if health < prev_health:
		timer.start()
	elif damage_bar:
		damage_bar.value = health

func init_health(_health):
	max_value = _health # Uses the max_value property of the Timer node
	health = max_value
	value = health # Uses the value property of the Timer node
	
	damage_bar.max_value = health
	damage_bar.value = health

func _on_timer_timeout():
	damage_bar.value = health
