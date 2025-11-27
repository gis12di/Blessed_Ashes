extends Node2D

@export var damage_per_tick: int = 5        # daño que hace cada intervalo
@export var tick_time: float = 0.5          # cada cuánto tiempo hace daño
@onready var player = $AudioStreamPlayer2D

var bodies_in_fire := {} # diccionario con cuerpos dentro del área

func _ready():
	var area = $Area2D
	var timer = $Timer

	# conectar señales
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	timer.timeout.connect(_on_tick)

	timer.wait_time = tick_time
	timer.start()
	
	# Asegurar que el sonido esté configurado
	setup_fire_sound()

func setup_fire_sound():
	if player.stream == null:
		var fire_sound = preload("res://JUEGO/sound/fire.wav")
		player.stream = fire_sound
	
	# Configuración EXTENDIDA para que se escuche en todo el nivel
	player.max_distance = 5000.0  # Muy grande
	player.attenuation = 0.75      # Atenuación más suave
	player.volume_db = 5       # Volumen moderado

func _on_body_entered(body):
	if body.has_method("take_damage"):
		bodies_in_fire[body.get_instance_id()] = body
		# Reproducir sonido cuando entra el primer cuerpo
		if bodies_in_fire.size() == 1 and not player.playing:
			player.play()

func _on_body_exited(body):
	if body.get_instance_id() in bodies_in_fire:
		bodies_in_fire.erase(body.get_instance_id())
		# Detener sonido cuando no hay más cuerpos
		if bodies_in_fire.is_empty() and player.playing:
			player.stop()

func _on_tick():
	for id in bodies_in_fire.keys():
		var b = bodies_in_fire[id]
		if not is_instance_valid(b):
			bodies_in_fire.erase(id)
			continue
		if b.has_method("take_damage"):
			b.take_damage(damage_per_tick)
