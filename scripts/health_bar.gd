extends ProgressBar

var health: int = 0 : set = _set_health
@export var label_on: bool = true

func _on_ready() -> void:
	if label_on:
		$Label.set_deferred("visible", true)

func _set_health(new_health: int):
	var prev_health = health
	health = min(max_value, new_health)
	value = health
	
	if label_on:
		$Label.text = str(int(value), "/", int(max_value))
	
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


func _on_label_resized() -> void:
	if label_on:
		$Label.add_theme_font_size_override("font_size", size.y * 0.9)
