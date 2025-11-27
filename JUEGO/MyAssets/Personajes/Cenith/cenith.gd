extends CharacterBody2D

const SPEED = 150.0
const JUMP_VELOCITY = -250.0

@export var max_health: int = 100
var current_health: int = max_health
var can_take_damage = true
var attack_input = false
var is_attacking = false

@onready var health_bar = $BarraVida/BarraVida

func _ready():
	is_attacking = false
	attack_input = false

	Global.playerBody = self
	Global.CenithAlive = true
	Global.CenithHitbox = $CenithHitbox
	Global.CenithDamageZone = $CenithDealDamageZone
	Global.CenithDamageAmount = 15
	
	$AnimatedSprite2D.play("Existir")
	
	# 🔥 IMPORTANTE: Desactivar la zona de daño al inicio
	$CenithDealDamageZone.monitoring = false
	$CenithDealDamageZone.monitorable = false
	
	# Configurar la barra de vida
	health_bar.max_value = max_health
	health_bar.value = current_health

func _physics_process(delta: float) -> void:
	check_hitbox()

	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Saltar
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("Salto")

	# Movimiento horizontal
	var direction := Input.get_axis("Izquierda", "Derecha") 

	if direction > 0:
		$AnimatedSprite2D.flip_h = false
	elif direction < 0:
		$AnimatedSprite2D.flip_h = true

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
		attack_input = false

	move_and_slide()

func check_hitbox():
	var hitbox_areas = $CenithHitbox.get_overlapping_areas()

	if hitbox_areas.size() == 0:
		return
	
	var hitbox = hitbox_areas.front()
	var damage = 0

	if hitbox.get_parent() is esqueleto:
		damage = Global.esqueletoDamageAmount
	
	elif hitbox.get_parent() is godofredo:
		damage = Global.godofredoDamageAmount
	
	elif hitbox.get_parent() is goblin:
		damage = Global.goblinDamageAmount
	
	elif hitbox.get_parent() is hongo:
		damage = Global.hongoDamageAmount
	
	elif hitbox.get_parent() is corredor:
		damage = Global.corredorDamageAmount
		
	elif hitbox.get_parent() is nymira:
		damage = Global.nymiraDamageAmount
	
	elif hitbox.get_parent() is nicromante:
		damage = Global.nicromanteDamageAmount
	#hola
		
	if damage > 0 and can_take_damage:                
		can_take_damage = false
		take_damage(damage)

		if current_health > 0 and Global.CenithAlive:
			start_damage_cooldown()

# 🔥 CORREGIDO: Verificar que estemos en el árbol
func start_damage_cooldown():
	if not is_inside_tree():
		return
	var timer = get_tree().create_timer(0.7)
	await timer.timeout
	if is_inside_tree():
		can_take_damage = true

func take_damage(amount: int) -> void:
	current_health -= amount
	health_bar.value = current_health  # Actualizar la barra
	print("🔥 Recibí daño:", amount, "| HP:", current_health)

	if current_health <= 0:
		Global.CenithAlive = false
		call_deferred("die")

func heal(amount: int):
	current_health += amount
	
	# Asegurar que no se pase del máximo
	if current_health > max_health:
		current_health = max_health
	
	# Actualizar barra de vida
	health_bar.value = current_health
	
	print("❤️ Curado: +", amount, " HP | HP actual: ", current_health)
	
	# Efecto visual opcional
	play_heal_effect()

func play_heal_effect():
	# Efecto visual simple - puedes mejorarlo
	var original_modulate = $AnimatedSprite2D.modulate
	$AnimatedSprite2D.modulate = Color.GREEN
	
	# Crear tween para restaurar el color
	var tween = create_tween()
	tween.tween_property($AnimatedSprite2D, "modulate", original_modulate, 0.5)

func die():
	print("💀 Jugador muerto")
	get_tree().call_deferred("reload_current_scene")

func _input(event):
	if event.is_action_pressed("atacar") and not is_attacking:
		attack_input = true

# 🔥 CORREGIDO: Ataque mejorado
func attack():
	if is_attacking:
		return

	is_attacking = true
	$AnimatedSprite2D.play("ataque")

	# 🔥 ACTIVAR la zona de daño solo durante el ataque
	$CenithDealDamageZone.monitoring = true
	$CenithDealDamageZone.monitorable = true

	# Aplicar daño después de un breve delay (para sincronizar con animación)
	await get_tree().create_timer(0.2).timeout
	
	# 🔥 SOLO aplicar daño si todavía estamos atacando
	if is_attacking and is_inside_tree():
		apply_attack_damage()

	# Esperar un poco más antes de desactivar (para que la animación termine visualmente)
	await get_tree().create_timer(0.3).timeout
	
	# 🔥 DESACTIVAR la zona de daño después del ataque
	if is_inside_tree():
		$CenithDealDamageZone.monitoring = false
		$CenithDealDamageZone.monitorable = false
	
	# Cooldown final antes de poder atacar de nuevo
	await get_tree().create_timer(0.1).timeout
	if is_inside_tree():
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
			print("🎯 Golpeé a: ", area.get_parent().name)
			
