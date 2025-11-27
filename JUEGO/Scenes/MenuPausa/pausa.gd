extends CanvasLayer

# Referencias a los nodos
@onready var resume_button = $VBoxContainer/Renaudar
@onready var options_button = $VBoxContainer/Opciones
@onready var main_menu_button = $VBoxContainer/MenuPrincipal
@onready var settings_menu = $SettingsMenu

var can_pause: bool = true  # 🔥 NUEVA VARIABLE: Controlar cuándo se puede pausar

func _ready():
	# Conectar señales de los botones
	resume_button.pressed.connect(_on_resume_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	main_menu_button.pressed.connect(_on_main_menu_button_pressed)
	
	# Ocultar el menú al inicio
	hide()
	
	# Conectar señal para cuando se cierre el menú de opciones
	settings_menu.popup_hide.connect(_on_settings_menu_closed)
	
	# 🔥 IMPORTANTE: Asegurar que procese input incluso cuando está oculto
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	# Tecla para abrir/cerrar pausa (por ejemplo, ESC)
	if event.is_action_pressed("ui_cancel") and can_pause:  # 🔥 Añadir condición
		if visible:
			resume_game()
		else:
			pause_game()
		
		# 🔥 IMPORTANTE: Marcar el evento como manejado
		get_viewport().set_input_as_handled()

func pause_game():
	# Mostrar menú de pausa
	show()
	# Pausar el juego
	get_tree().paused = true
	# Permitir que los botones reciban input
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# 🔥 Asegurar que los botones puedan recibir focus
	resume_button.grab_focus()

func resume_game():
	# Ocultar menú de pausa
	hide()
	# Reanudar el juego
	get_tree().paused = false
	
	# 🔥 Pequeño delay antes de permitir pausar nuevamente
	can_pause = false
	await get_tree().create_timer(0.2).timeout
	can_pause = true

func _on_resume_button_pressed():
	resume_game()

func _on_options_button_pressed():
	# Abrir el menú de opciones (popup)
	settings_menu.popup_centered()
	# 🔥 Cuando se abren opciones, no permitir pausar
	can_pause = false

func _on_main_menu_button_pressed():
	# Reanudar el juego antes de cambiar de escena
	get_tree().paused = false
	# Cambiar al menú principal
	get_tree().change_scene_to_file("res://JUEGO/Scenes/MenuPrincipal/menu_principal.tscn")  # 🔥 Actualiza esta ruta

func _on_settings_menu_closed():
	# Cuando se cierra el menú de opciones, el foco vuelve al menú de pausa
	options_button.grab_focus()
	# 🔥 Permitir pausar nuevamente
	can_pause = true
