extends inimigo_data
class_name Ini_TreantData

@export var escudo_max: float = 40.0

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	if not inimigo.estado_custom.has("iniciado"):
		inimigo.estado_custom["iniciado"] = true
		inimigo.estado_custom["estado"] = "com_escudo"
		inimigo.estado_custom["escudo_atual"] = escudo_max
		inimigo.estado_custom["vida_anterior"] = inimigo.vida_atual
		inimigo.estado_custom["timer_estado"] = 0.0

	var estado = inimigo.estado_custom["estado"]
	var timer = inimigo.estado_custom.get("timer_estado", 0.0) + delta
	inimigo.estado_custom["timer_estado"] = timer

	var dist = inimigo.global_position.distance_to(inimigo.player.global_position)
	var dir = inimigo.global_position.direction_to(inimigo.player.global_position)
	var sprite = inimigo.get_node("Sprite2D")
	
	if dir.x != 0:
		sprite.flip_h = dir.x < 0

	_processar_escudo(inimigo)

	match estado:
		"com_escudo":
			inimigo.modulate = Color(1.1, 1.4, 1.1)
			_mover_ou_atacar(inimigo, dir, dist, delta)

		"atordoado":
			inimigo.velocity = Vector2.ZERO
			inimigo.modulate = Color(0.7, 0.7, 0.7) # Cor cinza sem defesa
			if timer >= 2.5:
				inimigo.estado_custom["estado"] = "sem_escudo"
				inimigo.estado_custom["timer_estado"] = 0.0

		"sem_escudo":
			inimigo.modulate = Color(1.0, 1.0, 1.0)
			_mover_ou_atacar(inimigo, dir, dist, delta)
			
			if timer >= 7.0:
				inimigo.estado_custom["estado"] = "regenerando"
				inimigo.estado_custom["timer_estado"] = 0.0

		"regenerando":
			inimigo.velocity = Vector2.ZERO
			inimigo.modulate = Color(1.3, 1.8, 1.2)
			if timer >= 0.8:
				inimigo.estado_custom["escudo_atual"] = escudo_max
				inimigo.estado_custom["estado"] = "com_escudo"
				inimigo.estado_custom["timer_estado"] = 0.0

func _mover_ou_atacar(inimigo: CharacterBody2D, dir: Vector2, dist: float, delta: float) -> void:
	var atacando = inimigo.estado_custom.get("atacando", false)
	var timer_ataque = inimigo.estado_custom.get("timer_ataque", 0.0)
	
	if atacando:
		timer_ataque += delta
		inimigo.estado_custom["timer_ataque"] = timer_ataque
		inimigo.velocity = Vector2.ZERO
		
		if timer_ataque >= 0.5 and not inimigo.estado_custom.get("ja_bateu", false):
			inimigo.estado_custom["ja_bateu"] = true
			if dist <= 85.0:
				inimigo.player.take_damage(inimigo.data.dano)
		
		if timer_ataque >= 0.9:
			inimigo.estado_custom["atacando"] = false
			inimigo.estado_custom["timer_ataque"] = 0.0
	else:
		if dist <= 65.0:
			inimigo.estado_custom["atacando"] = true
			inimigo.estado_custom["timer_ataque"] = 0.0
			inimigo.estado_custom["ja_bateu"] = false
		else:
			inimigo.velocity = dir * inimigo.data.speed
			inimigo.move_and_slide()

func _processar_escudo(inimigo: CharacterBody2D) -> void:
	var vida_anterior = inimigo.estado_custom.get("vida_anterior", inimigo.vida_atual)
	
	if inimigo.vida_atual < vida_anterior:
		var dano_tomado = vida_anterior - inimigo.vida_atual
		
		if inimigo.estado_custom.get("estado") == "com_escudo":
			var absorvido = dano_tomado * 0.75
			inimigo.vida_atual = min(inimigo.vida_max, inimigo.vida_atual + absorvido)
			
			var escudo = inimigo.estado_custom.get("escudo_atual", 0.0) - dano_tomado
			inimigo.estado_custom["escudo_atual"] = escudo
			
			if escudo <= 0:
				inimigo.estado_custom["estado"] = "atordoado"
				inimigo.estado_custom["timer_estado"] = 0.0
	
	inimigo.estado_custom["vida_anterior"] = inimigo.vida_atual
