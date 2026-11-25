extends inimigo_data
class_name Ini_MagoGeloData

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.player:
		return
		
	var dist = inimigo.global_position.distance_to(inimigo.player.global_position)
	var dir = inimigo.global_position.direction_to(inimigo.player.global_position)
	
	if dist < 180.0:
		inimigo.velocity = -dir * inimigo.data.speed
	elif dist > 280.0:
		inimigo.velocity = dir * inimigo.data.speed
	else:
		inimigo.velocity = Vector2.ZERO
		
	inimigo.move_and_slide()
	
	var sprite = inimigo.get_node_or_null("Sprite2D")
	if sprite:
		if sprite.animation != "Atacando" or not sprite.is_playing():
			sprite.play("Idle")
		sprite.flip_h = (inimigo.player.global_position.x < inimigo.global_position.x)

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.player or not projetil:
		return
		
	var sprite = inimigo.get_node_or_null("Sprite2D")
	if sprite and sprite.sprite_frames.has_animation("Atacando"):
		sprite.play("Atacando")
		
	var buraco = projetil.instantiate()
	inimigo.get_parent().add_child(buraco)
	var spawn_pos = inimigo.player.global_position + Vector2.from_angle(randf() * TAU) * 90.0
	buraco.start(spawn_pos, Vector2.ZERO, inimigo.data.dano)
	
	var timer_acao = inimigo.get_node_or_null("AcaoTimer")
	if timer_acao:
		timer_acao.start(4.5)
