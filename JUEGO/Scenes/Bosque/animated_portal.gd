extends AnimatedSprite2D

func _ready():
	# Configurar que la animación sea en bucle
	sprite_frames.set_animation_loop("default", true)
	
	# Reproducir automáticamente la animación al cargar
	play("default")
