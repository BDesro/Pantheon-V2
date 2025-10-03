extends CanvasLayer

func _on_ready() -> void:
	GlobalData.player_health_bar = get_node("Control/NinePatchRect/HealthBar")
	GlobalData.unit_name_label = get_node("Control/NameLabel")
