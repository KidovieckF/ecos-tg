extends inimigo_data
class_name Ini_PinguimData

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	pass

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.player:
		return
		
	var fase = inimigo.estado_custom.get("fase", "parado")
	var timer = inimigo.estado_custom.get("timer", 0.0) + delta
	inimigo.estado_custom["timer"] = timer
	
	var sprite = inimigo.get_node_or_null("Sprite2D")
	
	match fase:
		"parado":
			inimigo.velocity = Vector2.ZERO
			inimigo.collision_layer = 4
			inimigo.collision_mask = 7
			
			if sprite:
				if sprite.animation != "Idle":
					sprite.play("Idle")
				sprite.flip_h = (inimigo.player.global_position.x > inimigo.global_position.x)
				
			if timer >= 1.2:
				var dir_inicial = inimigo.global_position.direction_to(inimigo.player.global_position)
				inimigo.estado_custom["dir_slide"] = dir_inicial
				inimigo.estado_custom["rebotes"] = 0
				inimigo.estado_custom["cd_rebote"] = 0.0
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["fase"] = "deslizando"
				
				inimigo.collision_layer = 0
				inimigo.collision_mask = 2
				
				_aplicar_excecoes_grupos(inimigo, true)
				
		"deslizando":
			var dir_slide: Vector2 = inimigo.estado_custom.get("dir_slide", Vector2.RIGHT)
			inimigo.velocity = dir_slide * (inimigo.data.speed * 3.0)
			inimigo.move_and_slide()
			
			if sprite:
				if sprite.animation != "Deslizando":
					sprite.play("Deslizando")
				sprite.flip_h = (dir_slide.x > 0)
				
			var cd_rebote = inimigo.estado_custom.get("cd_rebote", 0.0) - delta
			inimigo.estado_custom["cd_rebote"] = max(0.0, cd_rebote)
			
			if inimigo.get_slide_collision_count() > 0 and cd_rebote <= 0.0:
				var colisao = inimigo.get_last_slide_collision()
				var collider = colisao.get_collider()
				
				if collider and not collider.is_in_group("Players") and not collider.is_in_group("Inimigos"):
					var normal = colisao.get_normal()
					dir_slide = dir_slide.bounce(normal).normalized()
					inimigo.estado_custom["dir_slide"] = dir_slide
					inimigo.estado_custom["cd_rebote"] = 0.08
					
					var rebotes = inimigo.estado_custom.get("rebotes", 0) + 1
					inimigo.estado_custom["rebotes"] = rebotes
					
					if rebotes >= 4:
						_encerrar_deslize(inimigo)
						return
			
			if timer >= 5.0:
				_encerrar_deslize(inimigo)

func _encerrar_deslize(inimigo: CharacterBody2D) -> void:
	inimigo.velocity = Vector2.ZERO
	inimigo.collision_layer = 4
	inimigo.collision_mask = 7
	_aplicar_excecoes_grupos(inimigo, false)
	inimigo.estado_custom["fase"] = "parado"
	inimigo.estado_custom["timer"] = 0.0
	inimigo.estado_custom["rebotes"] = 0

func _aplicar_excecoes_grupos(inimigo: CharacterBody2D, ativar: bool) -> void:
	for grupo in ["Players", "Inimigos"]:
		for no in inimigo.get_tree().get_nodes_in_group(grupo):
			if no != inimigo and no is PhysicsBody2D:
				if ativar:
					inimigo.add_collision_exception_with(no)
				else:
					inimigo.remove_collision_exception_with(no)
