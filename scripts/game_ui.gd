extends CanvasLayer

func _on_ready() -> void:
	GlobalPlayerData.player_health_bar = get_node("Control/NinePatchRect/HealthBar")
	GlobalPlayerData.unit_name_label = get_node("Control/NinePatchRect/Label")
