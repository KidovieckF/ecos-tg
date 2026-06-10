extends inimigo_data
class_name Ini_AtiradorData


func acao(inimigo, delta):
	var novo_tiro = projetil.instantiate()
	inimigo.get_parent().add_child(novo_tiro)
	var direcao = (inimigo.player.global_position - inimigo.global_position).normalized()
	novo_tiro.global_position = inimigo.global_position
	novo_tiro.start(inimigo.global_position ,direcao)
	inimigo.get_node("AcaoTimer").start()

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	var distancia = inimigo.global_position.distance_to(inimigo.player.global_position)
	var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
	
	if direcao:
		if direcao.x > 0: 
			inimigo.last_direction = direcao
			inimigo.get_node("Sprite2D").flip_h = false
		elif direcao.x < 0:
			inimigo.last_direction = direcao
			inimigo.get_node("Sprite2D").flip_h = true
			
	if distancia > 150:
		inimigo.velocity = direcao * inimigo.data.speed
		inimigo.get_node("Sprite2D").play("Andando")
	elif distancia < 100:
		inimigo.velocity = -direcao * inimigo.data.speed
		inimigo.get_node("Sprite2D").play("Andando")
	else:
		inimigo.get_node("Sprite2D").play("Idle")
		inimigo.velocity = Vector2.ZERO
	inimigo.move_and_slide()
