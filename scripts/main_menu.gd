extends Node2D


func _ready() -> void:
	$CenterContainer/SettingsMenu/SettingsScrollList/SettingsVBox/Fullscreen.button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	
	$CenterContainer/SettingsMenu/SettingsScrollList/SettingsVBox/MainVolSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	$CenterContainer/SettingsMenu/SettingsScrollList/SettingsVBox/MusicVolSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("MUSIC")))
	$CenterContainer/SettingsMenu/SettingsScrollList/SettingsVBox/SFXVolSlider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/world.tscn")


func _on_settings_pressed() -> void:
	$CenterContainer/MainButtons.visible = false
	$CenterContainer/SettingsMenu/SettingsScrollList.scroll_vertical = 0 # Resets scroll bar to the top
	$CenterContainer/SettingsMenu.visible = true


func _on_credits_pressed() -> void:
	$CenterContainer/MainButtons.visible = false
	$CenterContainer/CreditsMenu.visible = true


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	$CenterContainer/MainButtons.visible = true
	$CenterContainer/SettingsMenu.visible = false
	$CenterContainer/CreditsMenu.visible = false

func _on_license_back_pressed() -> void:
	$CenterContainer/SettingsMenu.visible = true
	$CenterContainer/LicensePage.visible = false

func _on_licenses_pressed() -> void:
	$CenterContainer/SettingsMenu.visible = false
	
	var licenses = ""
	licenses += str("[b][u]MIT LICENSE[/u][/b]\n", Engine.get_license_text(), "\n\n")
	licenses += str("[b][u]THIRD PARTY LICENSES[/u][/b]\n", Engine.get_license_info(), "\n\n")
	licenses += str("[b][u]COPYRIGHT INFO[/u][/b]\n", Engine.get_copyright_info(), "\n\n")
	$CenterContainer/LicensePage/LicenseText.text = licenses
	$CenterContainer/LicensePage/LicenseText.scroll_to_line(0)
	$CenterContainer/LicensePage.visible = true


func _on_fullscreen_toggled(toggled_on: bool) -> void:
	if toggled_on: # Borderless fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else: # Windowed Fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_main_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)


func _on_music_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("MUSIC"), value)


func _on_sfx_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
