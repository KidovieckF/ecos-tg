extends inimigo_data
class_name Ini_LoboData

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	pass

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.player:
		return
		
	var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
	var distancia = inimigo.global_position.distance_to(inimigo.player.global_position)
	
	var fase = inimigo.estado_custom.get("fase", "perseguindo")
	var timer = inimigo.estado_custom.get("timer", 0.0) + delta
	inimigo.estado_custom["timer"] = timer
	
	match fase:
		"perseguindo":
			inimigo.velocity = direcao * inimigo.data.speed
			inimigo.move_and_slide()
			atualizar_animacao(inimigo, direcao)
			
			if distancia < 140.0:
				inimigo.estado_custom["fase"] = "preparando"
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["alvo"] = inimigo.player.global_position
				
		"preparando":
			inimigo.velocity = Vector2.ZERO
			if timer >= 0.3:
				inimigo.estado_custom["fase"] = "bote"
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["dir_bote"] = inimigo.global_position.direction_to(inimigo.estado_custom["alvo"])
				
		"bote":
			var dir_bote = inimigo.estado_custom.get("dir_bote", direcao)
			inimigo.velocity = dir_bote * (inimigo.data.speed * 2.2)
			inimigo.move_and_slide()
			atualizar_animacao(inimigo, dir_bote)
			
			if timer >= 0.35 or inimigo.is_on_wall():
				inimigo.estado_custom["fase"] = "recuperando"
				inimigo.estado_custom["timer"] = 0.0
				
		"recuperando":
			inimigo.velocity = Vector2.ZERO
			if timer >= 0.5:
				inimigo.estado_custom["fase"] = "perseguindo"
				inimigo.estado_custom["timer"] = 0.0

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
