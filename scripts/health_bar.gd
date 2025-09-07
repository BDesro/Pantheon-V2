extends ProgressBar

var health: float = 0 : set = _set_health

func _set_health(new_health: float):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	#if health <= 0:
		#queue_free()
	
	if health < prev_health:
		$Timer.start()
	elif $DamageBar:
		$DamageBar.value = health

func init_health(_health):
	max_value = _health # Uses the max_value property of the Timer node
	health = max_value
	value = health # Uses the value property of the Timer node
	
	$DamageBar.max_value = health
	$DamageBar.value = health

func _on_timer_timeout():
	$DamageBar.value = health
