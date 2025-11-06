extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saltar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("Saltar")  # 🔹 Reproduce animación de salto

	# Movimiento horizontal
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction > 0:
		$AnimatedSprite2D.flip_h = false  # Mirar a la derecha
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true   # Mirar a la izquierda

	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 🔹 Controlar animaciones según estado
	if not is_on_floor():
		$AnimatedSprite2D.play("Salto")  # Si está en el aire, reproducir salto
	elif direction != 0:
		$AnimatedSprite2D.play("Caminar")  # Si se mueve en el suelo
	else:
		$AnimatedSprite2D.play("Existir")  # Si está quieto en el suelo

	move_and_slide()
