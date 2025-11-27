extends CharacterBody2D

@onready var animation_player = $AnimationPlayer
@onready var chat_detection_area = $chat_detection_area
@onready var animated_sprite_2d = $AnimatedSprite2D

var player_in_range = false
var dialogue_active = false

# Diálogos del NPC
var dialogues = [
	"¡Hola Cenith! ¿Cómo estás?",
	"Este es un hermoso día para aventurarse.",
	"Ten cuidado con los monstruos en el bosque.",
	"¡Buena suerte en tu viaje!"
]
var current_dialogue_index = 0

func _ready():
	# Conectar señales del área de detección
	chat_detection_area.body_entered.connect(_on_player_entered)
	chat_detection_area.body_exited.connect(_on_player_exited)

func _process(_delta):
	# Verificar si el jugador está en rango y presiona E
	if player_in_range and Input.is_action_just_pressed("interactuar") and !dialogue_active:
		start_dialogue()

func _on_player_entered(body):
	if body.name == "Cenith" or body.is_in_group("player"):
		player_in_range = true
		# Mostrar indicador visual (opcional)
		show_interaction_indicator()

func _on_player_exited(body):
	if body.name == "Cenith" or body.is_in_group("player"):
		player_in_range = false
		# Ocultar indicador visual (opcional)
		hide_interaction_indicator()
		# Cerrar diálogo si está activo
		if dialogue_active:
			end_dialogue()

func start_dialogue():
	dialogue_active = true
	current_dialogue_index = 0
	
	# Pausar movimiento del jugador Cenith
	var cenith = get_tree().get_first_node_in_group("player")
	if cenith and cenith.has_method("set_dialogue_mode"):
		cenith.set_dialogue_mode(true)
	
	# Mostrar el primer diálogo
	show_dialogue()

func show_dialogue():
	if current_dialogue_index < dialogues.size():
		var current_dialogue = dialogues[current_dialogue_index]
		
		# Mostrar en la UI de diálogo
		get_tree().call_group("dialogue_ui", "show_dialogue", current_dialogue)
		
		# Animación del NPC (opcional)
		if animated_sprite_2d.has_animation("existe"):
			animated_sprite_2d.play("existe")
	else:
		end_dialogue()

func next_dialogue():
	current_dialogue_index += 1
	show_dialogue()

func end_dialogue():
	dialogue_active = false
	current_dialogue_index = 0
	
	# Reanudar movimiento del jugador Cenith
	var cenith = get_tree().get_first_node_in_group("player")
	if cenith and cenith.has_method("set_dialogue_mode"):
		cenith.set_dialogue_mode(false)
	
	# Ocultar UI de diálogo
	get_tree().call_group("dialogue_ui", "hide_dialogue")
	
	# Volver a animación idle
	if animated_sprite_2d.has_animation("idle"):
		animated_sprite_2d.play("idle")

func show_interaction_indicator():
	# Aquí puedes agregar un sprite o efecto que indique que se puede interactuar
	print("Presiona E para hablar con el NPC")

func hide_interaction_indicator():
	# Ocultar el indicador
	print("Fuera de rango")
