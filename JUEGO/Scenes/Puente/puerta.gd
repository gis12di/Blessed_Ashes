extends Area2D

@export var next_scene_path: String
var jugador_cerca := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Cenith":
		jugador_cerca = true

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Cenith":
		jugador_cerca = false

func _process(delta: float) -> void:
	if jugador_cerca and Input.is_action_just_pressed("interactuar"):
		get_tree().change_scene_to_file(next_scene_path)
