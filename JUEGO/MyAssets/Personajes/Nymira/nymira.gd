extends CharacterBody2D

class_name nymira

const speed = 20
var is_nymira_chase: bool = false  # Cambiado a false por defecto

var health = 150
var health_max = 150
var hearlt_min = 0

var dead : bool = false
var taking_damage : bool = false
var damage_to_deal = 10
var is_dealing_damage : bool = false

var dir : Vector2
const gravity = 900
var knockback_force = -20
var is_roaming : bool = true
var Cenith: CharacterBody2D
var Cenith_in_area = false

# Timer para el cooldown
var attack_cooldown_timer: Timer

# Variables para limitar la distancia
var initial_position: Vector2
const MAX_MOVEMENT_DISTANCE = 760  # Distancia máxima en píxeles desde la posición inicial
const DETECTION_DISTANCE = 750     # Distancia a la que detecta a Cenith

func _ready():
	# Guardar posición inicial
	initial_position = global_position
	
	# Crear timer para el cooldown de ataque
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	attack_cooldown_timer.timeout.connect(_on_attack_cooldown_finished)
	add_child(attack_cooldown_timer)

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	# Verificar si puede perseguir a Cenith
	update_chase_status()
		
	Global.nymiraDamageAmount = damage_to_deal
	Global.nymiraDamageZone = $nymiraDealDamageArea
	Cenith = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()

# Nueva función para actualizar el estado de persecución
func update_chase_status():
	if Global.CenithAlive and Cenith:
		var distance_to_cenith = global_position.distance_to(Cenith.global_position)
		var cenith_distance_from_start = Cenith.global_position.distance_to(initial_position)
		var my_distance_from_start = global_position.distance_to(initial_position)
		
		# Solo persigue si:
		# 1. Cenith está cerca para ser detectado
		# 2. Cenith está dentro del área de movimiento
		# 3. Yo estoy dentro del área de movimiento
		if (distance_to_cenith <= DETECTION_DISTANCE and 
			cenith_distance_from_start <= MAX_MOVEMENT_DISTANCE and 
			my_distance_from_start <= MAX_MOVEMENT_DISTANCE):
			is_nymira_chase = true
		else:
			is_nymira_chase = false
	else:
		is_nymira_chase = false

func move(delta):
	if !dead:
		if !is_nymira_chase:
			# Movimiento normal cuando no está persiguiendo
			velocity += dir * speed * delta
			
			# Verificar límites de distancia
			var distance_from_start = global_position.distance_to(initial_position)
			if distance_from_start >= MAX_MOVEMENT_DISTANCE:
				# Cambiar dirección hacia la posición inicial
				dir = global_position.direction_to(initial_position)
				velocity = dir * speed
				
		elif is_nymira_chase and !taking_damage:
			var dir_to_Cenith = position.direction_to(Cenith.position)
			
			# Verificar si ambos están dentro del área permitida
			var cenith_distance_from_start = Cenith.position.distance_to(initial_position)
			var my_distance_from_start = global_position.distance_to(initial_position)
			
			if cenith_distance_from_start <= MAX_MOVEMENT_DISTANCE and my_distance_from_start <= MAX_MOVEMENT_DISTANCE:
				# Perseguir normalmente
				velocity.x = dir_to_Cenith.x * speed
				dir.x = abs(velocity.x) / velocity.x if velocity.x != 0 else dir.x
			else:
				# Alguien está fuera del área, dejar de perseguir
				is_nymira_chase = false
				
		elif taking_damage:
			var knockback_dir = position.direction_to(Cenith.position) * knockback_force
			velocity.x = knockback_dir.x 
			
	elif dead:
		velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		if is_nymira_chase:
			anim_sprite.play("caminar")
		else:
			anim_sprite.play("caminar")  # O otra animación para cuando no persigue
		
		if dir.x == -1:
			anim_sprite.flip_h = true
		elif dir.x == 1:
			anim_sprite.flip_h = false
	elif !dead and taking_damage and !is_dealing_damage:
		anim_sprite.play("recibe_golpe")
		start_taking_damage_cooldown()
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("muerte")
		start_death_timer()
	elif !dead and is_dealing_damage:
		anim_sprite.play("ataque")

func start_taking_damage_cooldown():
	if is_inside_tree():
		var timer = get_tree().create_timer(0.8)
		timer.timeout.connect(_on_taking_damage_cooldown_finished)

func _on_taking_damage_cooldown_finished():
	if is_inside_tree():
		taking_damage = false

func start_death_timer():
	if is_inside_tree():
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(_on_death_timer_finished)

func _on_death_timer_finished():
	if is_inside_tree():
		handle_death()

func handle_death():
	self.queue_free()

func _on_direccion_timer_timeout():
	$DireccionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_nymira_chase:
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0

func choose(array):
	array.shuffle()
	return array.front()

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= hearlt_min:
		health = hearlt_min
		dead = true
	print(str(self), "current health is ", health)

func _on_nymira_deal_damage_area_area_entered(area: Area2D) -> void:
	if area == Global.CenithHitbox and not is_dealing_damage:
		is_dealing_damage = true

		if Global.playerBody and Global.playerBody.has_method("take_damage"):
			Global.playerBody.take_damage(damage_to_deal)

		start_attack_cooldown()

func start_attack_cooldown():
	if is_inside_tree() and attack_cooldown_timer:
		attack_cooldown_timer.start(1.0)

func _on_attack_cooldown_finished():
	is_dealing_damage = false

func _on_nymira_hitbox_area_entered(area: Area2D) -> void:
	var damage = Global.CenithDamageAmount
	if area == Global.CenithDamageZone: 
		take_damage(damage)
