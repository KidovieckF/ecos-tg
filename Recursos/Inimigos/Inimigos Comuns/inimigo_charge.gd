extends inimigo_data
class_name Ini_ChargeData



func acao(inimigo, delta):
	pass

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	var fase = inimigo.estado_custom.get("fase", "andando")
	match fase:
		"andando":
			var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
			inimigo.velocity = direcao * inimigo.data.speed * 0.5
			inimigo.move_and_slide()
			inimigo.estado_custom["timer"] = inimigo.estado_custom.get("timer", 0.0) + delta
			if inimigo.estado_custom["timer"] >= 2:
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["fase"] = "carregando"
		"carregando":
			inimigo.velocity = Vector2.ZERO
			
			inimigo.estado_custom["timer"] = inimigo.estado_custom.get("timer", 0.0) + delta
			if inimigo.estado_custom["timer"] >= 1.5:
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["alvo"] = inimigo.player.global_position
				inimigo.estado_custom["fase"] = "disparada"
				
		"disparada":
			var direcao = inimigo.global_position.direction_to(inimigo.estado_custom["alvo"])
			inimigo.velocity = direcao * inimigo.data.speed * 100
			inimigo.move_and_slide()
			if inimigo.is_on_wall() or (inimigo.global_position.distance_to(inimigo.estado_custom["alvo"]) <= 10):
				inimigo.estado_custom["fase"] = "stun"

		"stun":
			inimigo.velocity = Vector2.ZERO
			inimigo.estado_custom["timer"] = inimigo.estado_custom.get("timer", 0.0) + delta
			if inimigo.estado_custom["timer"] >= 1.5:
				inimigo.estado_custom["timer"] = 0.0
				inimigo.estado_custom["alvo"] = inimigo.player.global_position
				inimigo.estado_custom["fase"] = "andando"
