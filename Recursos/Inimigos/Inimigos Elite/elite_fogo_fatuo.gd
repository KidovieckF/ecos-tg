extends inimigo_data
class_name Ini_FogoFatuoData

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	var estado = inimigo.estado_custom.get("estado", "perseguindo")
	var timer = inimigo.estado_custom.get("timer", 0.0) + delta
	var tempo_vivo = inimigo.estado_custom.get("tempo_vivo", 0.0) + delta
	var sentido = inimigo.estado_custom.get("sentido", 1.0)
	
	inimigo.estado_custom["timer"] = timer
	inimigo.estado_custom["tempo_vivo"] = tempo_vivo
	inimigo.estado_custom["sentido"] = sentido

	var dist = inimigo.global_position.distance_to(inimigo.player.global_position)
	var dir = inimigo.global_position.direction_to(inimigo.player.global_position)

	inimigo.get_node("Sprite2D").flip_h = dir.x < 0

	match estado:
		"perseguindo":
			if dist > 220.0:
				inimigo.velocity = dir * inimigo.data.speed
			else:
				var tangencial = Vector2(-dir.y, dir.x) * sentido
				var radial = Vector2.ZERO
				if dist < 160.0:
					radial = -dir * 0.6  
				elif dist > 190.0:
					radial = dir * 0.6  
					
				var flutuacao = Vector2(0, sin(tempo_vivo * 5.0) * 15.0)
				inimigo.velocity = (tangencial + radial).normalized() * inimigo.data.speed + flutuacao

			inimigo.move_and_slide()

			if timer >= 3.0:
				inimigo.estado_custom["estado"] = "carregando"
				inimigo.estado_custom["timer"] = 0.0

		"carregando":
			inimigo.velocity = Vector2.ZERO
			inimigo.modulate = Color(2.5, 1.5, 0.4)
			
			if timer >= 0.4:
				disparar_leque(inimigo, dir)
				inimigo.estado_custom["sentido"] = -sentido 
				inimigo.modulate = Color(1.0, 1.0, 1.0)
				inimigo.estado_custom["estado"] = "perseguindo"
				inimigo.estado_custom["timer"] = 0.0

func disparar_leque(inimigo: CharacterBody2D, dir: Vector2) -> void:
	if not projetil:
		return
	
	var angulos = [-0.28, 0.0, 0.28]
	for ang in angulos:
		var dir_rotacionada = dir.rotated(ang)
		var tiro = projetil.instantiate()
		inimigo.get_parent().add_child(tiro)
		tiro.start(inimigo.global_position, dir_rotacionada)
