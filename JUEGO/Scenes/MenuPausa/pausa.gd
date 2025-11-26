extends CanvasLayer

func _ready():
	# Ocultar menú de pausa al inicio
	hide_pause_menu()
	
func _input(event):
	# Usar _input en lugar de _physics_process para inputs
	if event.is_action_pressed("Pausa"):
		toggle_pause()

func toggle_pause():
	# Alternar estado de pausa
	get_tree().paused = not get_tree().paused
	
	if get_tree().paused:
		show_pause_menu()
	else:
		hide_pause_menu()

func show_pause_menu():
	$ColorRect.visible = true
	$Label.visible = true

func hide_pause_menu():
	$ColorRect.visible = false
	$Label.visible = false
