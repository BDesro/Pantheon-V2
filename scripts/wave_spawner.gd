extends Node

@export var spawners: Array[NodePath]   # assign Spawner nodes in the inspector
@export var base_enemy_count := 3       # starting enemies
@export var scaling_factor := 1.5       # growth per wave
@export var base_max_delay := 3.0       # max random delay at wave 1
@export var delay_reduction := 0.2      # how much to reduce per wave (clamped)

var wave_number := 0
var enemies_alive := 0

func _on_ready():
	GlobalData.global_wave_spawner = self
	
	call_deferred("start_next_wave")

func start_next_wave():
	wave_number += 1
	
	GlobalData.wave_label.text = "Wave: " + str(wave_number)
	
	var enemy_count = int(base_enemy_count * pow(scaling_factor, wave_number - 1))
	print("Starting Wave ", wave_number, " with ", enemy_count, " enemies")
	spawn_wave(enemy_count)

func spawn_wave(count: int) -> void:
	for i in count:
		var spawner = get_node(spawners.pick_random())
		var enemy = spawner.spawn_enemy()
		
		enemy.get_node("EnemySnake").connect("enemy_died", Callable(self, "on_enemy_died"))
		
		enemies_alive += 1

		# compute max delay for this wave (gets smaller each wave)
		var max_delay = max(0.5, base_max_delay - (wave_number - 1) * delay_reduction)
		var delay = randf_range(0.0, max_delay)

		await get_tree().create_timer(delay).timeout

func on_enemy_died():
	enemies_alive -= 1
	if enemies_alive <= 0:
		await get_tree().create_timer(1.5).timeout # pause before next wave
		start_next_wave()
