extends Control

const ICON_SIZE = Vector2(64, 64)
const ICON_SPACING = 8

var ability_icon: PackedScene = preload("res://scenes/AbilityIcon.tscn")

func populate_abilities(character):
	# Remove old icons
	for child in get_children():
		child.queue_free()

	var x_offset = 0.0
	
	if GlobalData.global_player_instance.active_character:
		for ability in character.abilities:
			var cooldown: float = ability["cooldown"]
			var image: Texture2D = load(ability["image_path"])
			var mapped_key: String = ability["mapped_key"]
			
			var icon = ability_icon.instantiate()
			icon.set_icon_info(cooldown, image, mapped_key)
			
			icon.position = Vector2(x_offset, 0)
			add_child(icon)
			icon.size = ICON_SIZE
			x_offset += ICON_SIZE.x + ICON_SPACING
