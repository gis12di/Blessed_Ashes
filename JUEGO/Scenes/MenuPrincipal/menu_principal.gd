extends Control


func _on_jugar_pressed() -> void:
	print("saliendo del juego...")
	get_tree().change_scene_to_file("res://JUEGO/Scenes/Bosque/bosque.tscn")


func _on_opciones_pressed() -> void:
	print("saliendo del juego...")
	$SettingsMenu.popup()

func _on_salir_pressed() -> void:
	print("saliendo del juego...")
	get_tree().quit()
	
