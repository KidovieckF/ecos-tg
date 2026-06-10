extends inimigo_data
class_name Ini_MorcegoData



func acao(inimigo, delta):
	pass

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
	
	if direcao:
		if direcao.x > 0: 
			inimigo.last_direction = direcao
			inimigo.get_node("Sprite2D").flip_h = false
			inimigo.get_node("Sprite2D").play("Andando")
		elif direcao.x < 0:
			inimigo.last_direction = direcao
			inimigo.get_node("Sprite2D").flip_h = true
			inimigo.get_node("Sprite2D").play("Andando")
	inimigo.velocity = direcao * inimigo.data.speed
	inimigo.move_and_slide()
