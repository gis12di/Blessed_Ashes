extends Area2D

@export var heal_amount: int = 25
var can_heal: bool = true

func _ready():
	# Conectar señal cuando el jugador entra en el área
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Verificar si es el jugador y si puede curar
	if body.is_in_group("player") and can_heal:
		heal_player(body)

func heal_player(player):
	can_heal = false  # Prevenir múltiples curaciones
	
	# Verificar que el jugador tenga el método heal
	if player.has_method("heal"):
		player.heal(heal_amount)
	
	# Efecto visual/sonoro opcional
	play_pickup_effect()
	
	# Eliminar la poción después de un breve momento
	await get_tree().create_timer(0.1).timeout
	queue_free()

func play_pickup_effect():
	# Efecto visual simple - puedes expandir esto
	$Sprite2D.modulate = Color.GREEN
	# Aquí podrías añadir partículas o sonido
	
	# Animación simple de desvanecimiento
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property($Sprite2D, "scale", Vector2(0, 0), 0.2)
	tween.tween_callback(queue_free)
