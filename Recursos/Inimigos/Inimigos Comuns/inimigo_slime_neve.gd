extends inimigo_data
class_name Ini_SlimeNeveData

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	pass

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.player:
		return
		
	var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
	
	var timer = inimigo.estado_custom.get("timer", 0.0) + delta
	inimigo.estado_custom["timer"] = timer
	
	var ciclo = fmod(timer, 1.2)
	if ciclo < 0.6:
		inimigo.velocity = direcao * (inimigo.data.speed * 1.5)
		atualizar_animacao(inimigo, direcao)
	else:
		inimigo.velocity = inimigo.velocity.move_toward(Vector2.ZERO, 350.0 * delta)
		
	inimigo.move_and_slide()

func atualizar_animacao(inimigo: CharacterBody2D, direcao: Vector2) -> void:
	var sprite = inimigo.get_node_or_null("Sprite2D")
	if not sprite:
		return
		
	if abs(direcao.x) > abs(direcao.y):
		sprite.flip_h = (direcao.x > 0)
		sprite.play("Walk_side")
	else:
		sprite.flip_h = false
		if direcao.y > 0:
			sprite.play("Walk_front")
		else:
			sprite.play("Walk_back")
