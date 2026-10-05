extends Area2D

var vitoria_scene = preload("res://Cenas/Mundo/hud_vitoria.tscn")

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Players"):
		return
		
	# 1. Trava o jogador
	body.set_physics_process(false)
	
	# 2. Desativa as câmeras para ela não seguir o jogador para fora da tela
	for child in body.get_children():
		if child is Camera2D:
			child.set_physics_process(false) # Desativa o script da câmera! (camera_2d.gd)
			child.set_process(false)
			var pos_atual = child.global_position
			child.top_level = true
			child.global_position = pos_atual
	
	# 3. Animação de andar para a direita
	var sprite_player = body.get_node("Sprite2D")
	sprite_player.flip_h = false
	sprite_player.play("AndandoLado")
	
	# 4. Faz o Tween empurrando o player pra direita para fora da tela
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	var alvo_x = body.global_position.x + 200 # Anda 200 pixels pra direita
	tween.tween_property(body, "global_position:x", alvo_x, 1.5)
	
	# 5. Quando terminar, carrega o Lobby
	tween.tween_callback(func():
		RunData.guardar_player(body)
		RunData.avancar_andar()
		if RunData.andar > 2:
			var vitoria_hud = vitoria_scene.instantiate()
			add_child(vitoria_hud)
		else:
			get_tree().change_scene_to_file("res://Cenas/Mundo/LobbyPrincipal.tscn")
	)
