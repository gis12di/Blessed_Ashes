extends Control



func _on_InicioBtn_pressed() -> void:
	get_tree().change_scene_to_file("res://MundoJugable.tscn")


func _on_SettingsBtn_pressed() -> void:
	$SettingsMenu.popup()


func _on_ExitBtn_pressed() -> void:
	get_tree().quit()
