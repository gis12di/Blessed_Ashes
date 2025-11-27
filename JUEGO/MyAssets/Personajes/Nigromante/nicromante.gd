extends CharacterBody2D

class_name nicromante

const speed = 20
var is_nicromante_chase: bool = true

var health = 100
var health_max = 100
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

# Añadir timer para el cooldown
var attack_cooldown_timer: Timer

func _ready():
	# Crear timer para el cooldown de ataque
	attack_cooldown_timer = Timer.new()
	attack_cooldown_timer.one_shot = true
	add_child(attack_cooldown_timer)
	
	# 🔥 INICIALIZAR: Asegurar que las variables globales existan
	_initialize_global_variables()

func _initialize_global_variables():
	# Inicializar variables globales si no existen
	if not "nicromanteDamageAmount" in Global:
		Global.nicromanteDamageAmount = damage_to_deal
	if not "nicromanteDamageZone" in Global:
		Global.nicromanteDamageZone = null

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	if Global.CenithAlive:
		is_nicromante_chase = true
	elif !Global.CenithAlive:
		is_nicromante_chase = false
		
	# 🔥 CORREGIDO: Verificar que exista el nodo antes de asignar
	if has_node("nicromanteDealDamageArea"):
		Global.nicromanteDamageZone = $nicromanteDealDamageArea
	else:
		print("⚠️ Advertencia: nicromanteDealDamageArea no encontrado")
	
	Global.nicromanteDamageAmount = damage_to_deal
	Cenith = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	if !dead:
		if !is_nicromante_chase:
			velocity += dir * speed * delta
		elif is_nicromante_chase and !taking_damage:
			var dir_to_Cenith = position.direction_to(Cenith.position) * speed
			velocity.x = dir_to_Cenith.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir = position.direction_to(Cenith.position) * knockback_force
			velocity.x = knockback_dir.x 
		is_roaming = true
	elif dead:
		velocity.x = 0

func handle_animation():
	var anim_sprite = $AnimatedSprite2D
	if !dead and !taking_damage and !is_dealing_damage:
		anim_sprite.play("caminar")
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

# Nuevo método para el cooldown de daño
func start_taking_damage_cooldown():
	if is_inside_tree():
		var timer = get_tree().create_timer(0.8)
		timer.timeout.connect(_on_taking_damage_cooldown_finished)

func _on_taking_damage_cooldown_finished():
	if is_inside_tree():
		taking_damage = false

# Nuevo método para el timer de muerte
func start_death_timer():
	if is_inside_tree():
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(_on_death_timer_finished)

func _on_death_timer_finished():
	if is_inside_tree():
		handle_death()

func handle_death():
	# 50% de probabilidad de soltar poción
	if randf() < 0.5:
		drop_health_potion()
	
	self.queue_free()

func drop_health_potion():
	# Cargar la escena de la poción
	var health_potion_scene = load("res://JUEGO/MyAssets/Personajes/Cenith/posion/health_potion.tscn")
	
	# 🔥 CORREGIDO: Verificar que la escena existe
	if health_potion_scene == null:
		print("❌ Error: No se pudo cargar la escena de la poción")
		return
	
	var health_potion = health_potion_scene.instantiate()
	
	# Añadir la poción al mismo nivel que el enemigo (el padre del enemigo)
	get_parent().add_child(health_potion)
	
	# Posicionar la poción donde murió el enemigo
	health_potion.global_position = global_position
	
	print("🎁 Poción soltada!")

func _on_direccion_timer_timeout():
	$DireccionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_nicromante_chase:
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

func _on_nicromante_deal_damage_area_area_entered(area: Area2D) -> void:
	# 🔥 CORREGIDO: Verificación más segura
	if Global.CenithHitbox and area == Global.CenithHitbox:
		is_dealing_damage = true

		# APLICAR DAÑO REAL
		if Global.playerBody and Global.playerBody.has_method("take_damage"):
			Global.playerBody.take_damage(damage_to_deal)

		# COOL DOWN - Versión segura
		start_attack_cooldown()

# Nuevo método para el cooldown de ataque
func start_attack_cooldown():
	if is_inside_tree() and attack_cooldown_timer:
		attack_cooldown_timer.start(1.0)
		await attack_cooldown_timer.timeout
		if is_inside_tree():
			is_dealing_damage = false

func _on_nicromante_hitbox_area_entered(area: Area2D) -> void:
	# 🔥 CORREGIDO: Verificación más segura
	if Global.CenithDamageZone and area == Global.CenithDamageZone:
		var damage = Global.CenithDamageAmount
		take_damage(damage)
