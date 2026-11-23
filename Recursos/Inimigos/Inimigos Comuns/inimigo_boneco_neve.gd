extends inimigo_data
class_name Ini_BonecoNeveData

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	inimigo.velocity = Vector2.ZERO
	var sprite = inimigo.get_node_or_null("Sprite2D")
	if sprite:
		sprite.play("Idle")
		if inimigo.player:
			sprite.flip_h = (inimigo.player.global_position.x > inimigo.global_position.x)

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.player or not projetil:
		return
		
	var novo_tiro = projetil.instantiate()
	inimigo.get_parent().add_child(novo_tiro)
	var direcao = (inimigo.player.global_position - inimigo.global_position).normalized()
	novo_tiro.global_position = inimigo.global_position
	novo_tiro.start(inimigo.global_position, direcao, inimigo.data.dano)
	
	var timer_acao = inimigo.get_node_or_null("AcaoTimer")
	if timer_acao:
		timer_acao.start(2.2)
