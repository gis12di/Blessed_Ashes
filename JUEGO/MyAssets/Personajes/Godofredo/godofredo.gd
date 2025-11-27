extends CharacterBody2D

class_name godofredo

const speed = 30
var is_godofredo_chase: bool = true

var health = 150
var health_max = 150
var health_min = 0

var dead : bool = false
var taking_damage : bool = false
var damage_to_deal = 20
var is_dealing_damage : bool = false

var dir : Vector2
const gravity = 900
var knockback_force = -20
var is_roaming : bool = true
var Cenith: CharacterBody2D
var Cenith_in_area = false

# Añadir timer para el cooldown
var attack_cooldown_timer: Timer

func _ready():
	# Crear timer para el cooldown de ataque
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	add_child(attack_cooldown_timer)

func _process(delta):
	if dead:
		return
		
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	if Global.CenithAlive:
		is_godofredo_chase = true
	else:
		is_godofredo_chase = false
		
	Global.godofredoDamageAmount = damage_to_deal
	Global.godofredoDamageZone = $godofredoDealDamageArea
	Cenith = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	if dead:
		velocity.x = 0
		return
		
	if !is_godofredo_chase:
		velocity += dir * speed * delta
	elif is_godofredo_chase and !taking_damage and !is_dealing_damage:  # 🔥 NUEVO: No moverse durante ataque
		var dir_to_Cenith = position.direction_to(Cenith.position) * speed
		velocity.x = dir_to_Cenith.x
		if velocity.x != 0:
			dir.x = abs(velocity.x) / velocity.x
	elif taking_damage:
		var knockback_dir = position.direction_to(Cenith.position) * knockback_force
		velocity.x = knockback_dir.x 
	elif is_dealing_damage:  # 🔥 NUEVO: Detener movimiento durante ataque
		velocity.x = 0
		
	is_roaming = true

func handle_animation():
	if dead:
		$AnimatedSprite2D.play("muerte")
		return
		
	var anim_sprite = $AnimatedSprite2D
	if taking_damage:
		anim_sprite.play("recibe_golpe")
	elif is_dealing_damage:
		anim_sprite.play("ataca")
	else:
		anim_sprite.play("camina")
		if dir.x > 0:
			anim_sprite.flip_h = true
		elif dir.x < 0:
			anim_sprite.flip_h = false

var taking_damage_cooldown_started = false

func start_taking_damage_cooldown():
	if not taking_damage_cooldown_started:
		taking_damage_cooldown_started = true
		var timer = get_tree().create_timer(0.8)
		timer.timeout.connect(_on_taking_damage_cooldown_finished)

func _on_taking_damage_cooldown_finished():
	if is_inside_tree():
		taking_damage = false
		taking_damage_cooldown_started = false

func take_damage(damage):
	if dead or taking_damage:
		return
		
	health -= damage
	taking_damage = true
	print(str(self), " current health is ", health)
	
	if health <= health_min:
		health = health_min
		dead = true
		handle_death()
	else:
		start_taking_damage_cooldown()

func handle_death():
	$AnimatedSprite2D.play("muerte")
	await get_tree().create_timer(1.0).timeout
	if is_inside_tree():
		call_deferred("queue_free")

func _on_direccion_timer_timeout():
	if dead:
		return
		
	$DireccionTimer.wait_time = choose([1.5, 2.0, 2.5])
	if !is_godofredo_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func _on_godofredo_deal_damage_area_area_entered(area: Area2D) -> void:
	if dead or is_dealing_damage:
		return
		
	if area == Global.CenithHitbox:
		is_dealing_damage = true
		
		# 🔥 NUEVO: Esperar a que la animación de ataque se reproduzca
		# Aplicar daño después de un breve delay para sincronizar con animación
		await get_tree().create_timer(0.3).timeout  # Ajusta este tiempo según tu animación
		
		# APLICAR DAÑO REAL (solo si sigue atacando)
		if is_dealing_damage and Global.playerBody and Global.playerBody.has_method("take_damage"):
			Global.playerBody.take_damage(damage_to_deal)
			print("Godofredo atacó a Cenith")

		# 🔥 NUEVO: Esperar a que termine la animación completa
		await get_tree().create_timer(0.5).timeout  # Tiempo total de la animación de ataque
		
		# COOL DOWN
		start_attack_cooldown()

# 🔥 CORREGIDO: Cooldown mejorado
func start_attack_cooldown():
	if is_inside_tree() and attack_cooldown_timer:
		attack_cooldown_timer.start(0.5)  # Cooldown después del ataque
		await attack_cooldown_timer.timeout
		if is_inside_tree():
			is_dealing_damage = false
			print("Godofredo puede atacar de nuevo")

func _on_godofredo_hitbox_area_entered(area: Area2D) -> void:
	if dead:
		return
		
	var damage = Global.CenithDamageAmount
	if area == Global.CenithDamageZone: 
		take_damage(damage)
