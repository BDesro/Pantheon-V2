extends Control
class_name AbilityIcon

@export var cooldown_duration: float = 3.0
@export var icon_texture: Texture2D
@export var mapped_key: String

@onready var icon_base = $PanelContainer/IconBase
@onready var icon_gray = $PanelContainer/IconGray
@onready var highlight = $PanelContainer/Highlight
@onready var name_label = $NameLabel

var cooldown_remaining: float = 0.0

func _ready():
	icon_base.texture = icon_texture
	icon_gray.texture = icon_texture
	highlight.visible = false
	name_label.text = mapped_key

# To be used by implementing scripts (GlobalData, Player, etc.)
func set_icon_info(cooldown: float, image: Texture2D, key: String):
	cooldown_duration = cooldown
	icon_texture = image
	mapped_key = key

func _process(delta: float):
	if Input.is_action_just_pressed(mapped_key):
		trigger_ability()
	
	if cooldown_remaining > 0:
		cooldown_remaining -= delta
		if cooldown_remaining <= 0:
			cooldown_remaining = 0
			icon_gray.visible = false
		else:
			icon_gray.visible = true
			icon_gray.material.set("shader_param/cooldown_percent", cooldown_remaining / cooldown_duration)

func trigger_ability():
	if cooldown_remaining == 0:
		_flash_highlight(Color(100, 100, 100, 0.8)) # Should be a pale gray
		start_cooldown()
	else:
		_flash_highlight(Color(210/255.0, 77/255.0, 87/255.0, 0.8)) # Should be red

func start_cooldown():
	cooldown_remaining = cooldown_duration

var _highlight_tween: Tween = null
func _flash_highlight(color: Color):
	highlight.visible = true
	highlight.color = color
	
	highlight.modulate = Color(1, 1, 1, color.a)
	
	# Kill any existing tween that might still be running
	if _highlight_tween:
		_highlight_tween.kill()
		_highlight_tween = null

	# Create a new tween that fades modulate.a -> 0 then hides and restores alpha
	_highlight_tween = get_tree().create_tween()
	_highlight_tween.tween_property(highlight, "modulate:a", 0.0, 0.4)
	_highlight_tween.tween_callback(self._on_highlight_finished)

func _on_highlight_finished():
	# hide and reset for the next flash
	highlight.visible = false
	highlight.modulate = Color(1, 1, 1, 1.0)
	_highlight_tween = null
