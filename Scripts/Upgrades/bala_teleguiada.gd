extends Node

var alvo = null

func _process(delta):
	var bala = get_parent()
	print("print: ", bala)
	if alvo == null or not is_instance_valid(alvo):
		print("alvo: ", alvo)
		alvo = _procurar_alvo(bala)
		
	if is_instance_valid(alvo):
		var direcao_desejada = (alvo.global_position - bala.global_position).normalized()
		bala.direction = bala.direction.move_toward(direcao_desejada, 5.0 * delta).normalized()

func _procurar_alvo(bala):
	var todos_inimigos = bala.get_tree().get_nodes_in_group("Inimigos")
	var menor_distancia = 99999.0
	var alvo_escolhido = null
	
	for inimigo in todos_inimigos:
		if is_instance_valid(inimigo):
			var dist = bala.global_position.distance_to(inimigo.global_position)
			if dist < menor_distancia:
				menor_distancia = dist
				alvo_escolhido = inimigo
	return alvo_escolhido
