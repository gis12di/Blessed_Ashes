extends CharacterBody2D

class_name esqueleto

const speed = 30
var is_esqueleto_chase: bool = true

var health = 300
var health_max = 300
var hearlt_min = 0

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

func _process(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
		velocity.x = 0
		
	if Global.CenithAlive:
		is_esqueleto_chase = true
	elif !Global.CenithAlive:
		is_esqueleto_chase = false
		
	Global.esqueletoDamageAmount = damage_to_deal
	Global.esqueletoDamageZone = $esqueletoDealDamageArea
	Cenith = Global.playerBody
	move(delta)
	handle_animation()
	move_and_slide()

func move(delta):
	if !dead:
		if !is_esqueleto_chase:
			velocity += dir * speed * delta
		elif is_esqueleto_chase and !taking_damage:
			var dir_to_Cenith = position.direction_to(Cenith.position) * speed
			velocity.x = dir_to_Cenith.x
			dir.x = abs(velocity.x) / velocity.x
		elif taking_damage:
			var knockback_dir =position.direction_to(Cenith.position) * knockback_force
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
		await get_tree().create_timer(0.8).timeout
		taking_damage = false
	elif dead and is_roaming:
		is_roaming = false
		anim_sprite.play("muerte")
		await get_tree().create_timer(1.0).timeout
		handle_death()
	elif !dead and is_dealing_damage:
		anim_sprite.play("ataque")

func handle_death():
	self.queue_free()

func _on_direccion_timer_timeout():
	$DireccionTimer.wait_time = choose([1.5,2.0,2.5])
	if !is_esqueleto_chase :
		dir = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0
	

func choose(array):
	array.shuffle()
	return array.front()


func _on_area_2d_area_entered(area: Area2D) -> void:
	var damage =Global.CenithDamageAmount
	if area == Global.CenithDamageZone: 
		take_damage(damage)

func take_damage(damage):
	health -= damage
	taking_damage = true
	if health <= hearlt_min:
		health = hearlt_min
		dead = true
	print(str(self), "current health is ", health)
		


func _on_esqueleto_deal_damage_area_area_entered(area: Area2D) -> void:
	if area == Global.CenithHitbox:
		is_dealing_damage = true

		# APLICAR DAÑO REAL
		if Global.playerBody and Global.playerBody.has_method("take_damage"):
			Global.playerBody.take_damage(damage_to_deal)

		# COOL DOWN
		await get_tree().create_timer(1.0).timeout
		is_dealing_damage = false
