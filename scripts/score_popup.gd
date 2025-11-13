extends Control
class_name ScorePopup

@onready var score_label = $Label
@onready var anim_player = $AnimationPlayer

func _on_ready() -> void:
	var final_y_position = global_position.y - 10
	
	var tween = get_tree().create_tween()
	tween.tween_property(score_label, "global_position:y", final_y_position, 1.0)
	tween.tween_property(score_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(self._on_anim_finished)

func _on_anim_finished():
	queue_free()
