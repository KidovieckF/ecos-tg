extends inimigo_data
class_name Ini_PlantaCarnivoraData

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	inimigo.velocity = Vector2.ZERO
	
	var fase = inimigo.estado_custom.get("fase", "idle")
	var timer = inimigo.estado_custom.get("timer", 0.0) + delta
	inimigo.estado_custom["timer"] = timer
	
	var sprite = inimigo.get_node("Sprite2D")
	var dir = inimigo.global_position.direction_to(inimigo.player.global_position)
	var sufixo = obter_sufixo_direcao(dir, sprite)

	match fase:
		"idle":
			sprite.play("Idle_" + sufixo)
			if timer >= 1.0:
				# Inicia o ataque
				sprite.play("Ataque_" + sufixo)
				inimigo.estado_custom["fase"] = "atacando"
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["ja_disparou"] = false
				
		"atacando":
			if timer >= 0.3 and not inimigo.estado_custom.get("ja_disparou", false):
				atirar(inimigo, dir)
				inimigo.estado_custom["ja_disparou"] = true
			
			if timer >= 0.6:
				inimigo.estado_custom["fase"] = "submergindo"
				inimigo.estado_custom["timer"] = 0.0
				
		"submergindo":
			inimigo.modulate.a = move_toward(inimigo.modulate.a, 0.0, delta * 3.0)
			inimigo.get_node("Hurtbox/CollisionShape2D").disabled = true
			
			if timer >= 0.6:
				relocar_no_chao_longe_do_player(inimigo)
				inimigo.estado_custom["fase"] = "emergindo"
				inimigo.estado_custom["timer"] = 0.0
				
		"emergindo":
			sprite.play("Idle_" + sufixo)
			inimigo.modulate.a = move_toward(inimigo.modulate.a, 1.0, delta * 3.0)
			
			if timer >= 0.4:
				inimigo.modulate.a = 1.0
				inimigo.get_node("Hurtbox/CollisionShape2D").disabled = false
				inimigo.estado_custom["fase"] = "idle"
				inimigo.estado_custom["timer"] = 0.0

func atirar(inimigo: CharacterBody2D, dir: Vector2) -> void:
	if not projetil:
		return
	var tiro = projetil.instantiate()
	inimigo.get_parent().add_child(tiro)
	tiro.start(inimigo.global_position, dir)

func obter_sufixo_direcao(dir: Vector2, sprite: AnimatedSprite2D) -> String:
	if abs(dir.y) > abs(dir.x):
		sprite.flip_h = false
		return "front" if dir.y > 0 else "back"
	else:
		sprite.flip_h = (dir.x > 0)
		return "side"

func relocar_no_chao_longe_do_player(inimigo: CharacterBody2D) -> void:
	var sala = inimigo.get_parent()
	var chao = sala.get_node_or_null("Chao")
	if not chao:
		chao = sala.get_node_or_null("Chão")
		
	if chao:
		var celulas = chao.get_used_cells()
		if celulas.size() > 0:
			for i in range(15):
				var celula_aleatoria = celulas.pick_random()
				var pos_global = chao.to_global(chao.map_to_local(celula_aleatoria))
				# Garante que brote a pelo menos 220px do player para dar espaço
				if pos_global.distance_to(inimigo.player.global_position) >= 220.0:
					inimigo.global_position = pos_global
					return
