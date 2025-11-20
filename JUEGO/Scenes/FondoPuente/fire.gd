extends Node2D

@export var damage_per_tick: int = 5        # daño que hace cada intervalo
@export var tick_time: float = 0.5          # cada cuánto tiempo hace daño

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

func _on_body_entered(body):
	if body.has_method("take_damage"):
		bodies_in_fire[body.get_instance_id()] = body

func _on_body_exited(body):
	bodies_in_fire.erase(body.get_instance_id())

func _on_tick():
	for id in bodies_in_fire.keys():
		var b = bodies_in_fire[id]
		if not is_instance_valid(b):
			bodies_in_fire.erase(id)
			continue
		if b.has_method("take_damage"):
			b.take_damage(damage_per_tick)
