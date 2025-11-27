extends Node2D

@onready var player=$AudioStreamPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.play()
	pass # Replace with function body.


func _on_brasero_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
