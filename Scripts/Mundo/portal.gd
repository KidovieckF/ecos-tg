extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		# Desabilita o controle do jogador para a cutscene
		body.set_physics_process(false)
		
		# Força a animação de andar para cima (costas)
		body.get_node("Sprite2D").play("AndandoCosta")
		
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		
		# Move o player para o centro do portal e para cima até sair da tela
		var alvo_x = global_position.x
		var alvo_y = global_position.y - 150 # Distância para sair da tela
		
		tween.tween_property(body, "global_position", Vector2(alvo_x, alvo_y), 1.5)
		
		# Quando a animação terminar, carrega o mundo
		tween.tween_callback(func():
			RunData.guardar_player(get_tree().get_first_node_in_group("Players"))
			get_tree().change_scene_to_file("res://Cenas/Mundo/Mundo.tscn")
			body.trocar_camera()
		)
