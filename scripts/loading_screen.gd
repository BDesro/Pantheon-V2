extends CanvasLayer

@onready var loading_ring = $LoadingRing

var loader = ResourceLoader.load_threaded_request("res://scenes/world.tscn")

# If world actually needs time to load, use this instead, the other one is for show
#func _process(delta):
	#await $Timer.timeout
	#
	#var status = ResourceLoader.load_threaded_get_status("res://scenes/world.tscn", [])
	#
	#if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		#var tween = create_tween()
		#tween.tween_property(loading_ring, "value", ResourceLoader.load_threaded_get_status("res://scenes/world.tscn") * 100, 2)
		## loading_ring.value = ResourceLoader.load_threaded_get_status("res://scenes/world.tscn") * 100
	#elif status == ResourceLoader.THREAD_LOAD_LOADED:
		#get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get("res://scenes/world.tscn"))

var load_progress := 0.0

func _process(delta):
	if load_progress < 100:
		load_progress += delta * 25.0
		_update_ring_value(load_progress)
	else:
		get_tree().change_scene_to_file("res://scenes/world.tscn")

func _update_ring_value(target_value: float):
	var tween = create_tween()
	tween.tween_property(loading_ring, "value", target_value, 0.2)
