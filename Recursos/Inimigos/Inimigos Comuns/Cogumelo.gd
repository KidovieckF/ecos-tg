extends inimigo_data
class_name Ini_CogumeloData

var cena_explosao = preload("res://Cenas/Inimigos/Efeitos/Explosao_cogumelo.tscn")

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	var fase = inimigo.estado_custom.get("fase", "andando")
	
	match fase:
		"andando":
			var dist = inimigo.global_position.distance_to(inimigo.player.global_position)
			var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
			
			if direcao.x != 0:
				inimigo.get_node("Sprite2D").flip_h = (direcao.x < 0)
			
			inimigo.velocity = direcao * inimigo.data.speed
			inimigo.get_node("Sprite2D").play("Andando")
			inimigo.move_and_slide()
			
			if dist <= 50.0:
				inimigo.estado_custom["fase"] = "armando"
				inimigo.estado_custom["timer"] = 0.0
				
		"armando":
			inimigo.velocity = Vector2.ZERO
			inimigo.modulate = Color(2.0, 0.4, 0.4)
			inimigo.get_node("Sprite2D").play("Explodindo")
			inimigo.estado_custom["timer"] = inimigo.estado_custom.get("timer", 0.0) + delta
			
			if inimigo.estado_custom["timer"] >= 0.7:
				explodir(inimigo)

func explodir(inimigo: CharacterBody2D) -> void:
	inimigo.get_node("Sprite2D").play("Explodindo")
	var exp_inst = cena_explosao.instantiate()
	exp_inst.global_position = inimigo.global_position
	inimigo.get_parent().add_child(exp_inst)
	inimigo.queue_free()
