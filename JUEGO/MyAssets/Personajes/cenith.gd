extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@export var max_health: int = 100
var current_health: int = max_health
var can_take_damage = true
var attack_input = false
var is_attacking = false


func _ready():
	Global.playerBody = self
	Global.CenithAlive = true
	Global.CenithHitbox = $CenithHitbox
	Global.CenithDamageZone = $CenithDealDamageZone
	Global.CenithDamageAmount = 15

func _physics_process(delta: float) -> void:
	check_hitbox()

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
		
	if is_attacking:
		move_and_slide()
		return

	
	if not is_on_floor():
		$AnimatedSprite2D.play("Salto")
	elif direction != 0:
		$AnimatedSprite2D.play("Caminar")
	else:
		$AnimatedSprite2D.play("Existir")
	
	if attack_input:
		attack()
		attack_input=false

	move_and_slide()

func check_hitbox():
	var hitbox_areas = $CenithHitbox.get_overlapping_areas()

	if hitbox_areas.size() == 0:
		return
	
	var hitbox = hitbox_areas.front()
	var damage = 0

	if hitbox.get_parent() is esqueleto:
		damage = Global.esqueletoDamageAmount

	if damage > 0 and can_take_damage:                
		can_take_damage = false
		take_damage(damage)

		# NO activar cooldown si ya murió
		if current_health > 0 and Global.CenithAlive:
			start_damage_cooldown()


func start_damage_cooldown():
	await get_tree().create_timer(0.7).timeout
	can_take_damage = true


		
# 💥 --- Sistema de daño ---
func take_damage(amount: int) -> void:
	current_health -= amount
	print("🔥 Recibí daño:", amount, "| HP:", current_health)

	if current_health <= 0:
		Global.CenithAlive = false
		die()


func die():
	print("💀 Jugador muerto")
	get_tree().reload_current_scene()

func _input(event):
	if event.is_action_pressed("atacar"): 
		attack_input = true

func attack():
	if is_attacking:
		return  # Evitar spamear el ataque

	is_attacking = true
	$AnimatedSprite2D.play("ataque")

	$CenithDealDamageZone.monitoring = true
	$CenithDealDamageZone.monitorable = true

	await get_tree().create_timer(0.2).timeout
	apply_attack_damage()

	$CenithDealDamageZone.monitoring = false
	$CenithDealDamageZone.monitorable = false

	# Espera un poco más para que la animación termine
	await get_tree().create_timer(0.6).timeout
	is_attacking = false



func apply_attack_damage():
	var areas = $CenithDealDamageZone.get_overlapping_areas()

	for area in areas:
		# Evitar que el jugador se golpee a sí mismo
		if area.get_parent() == self:
			continue
		# Atacar solo si el padre tiene método de daño
		if area.get_parent().has_method("take_damage"):
			area.get_parent().take_damage(Global.CenithDamageAmount)
