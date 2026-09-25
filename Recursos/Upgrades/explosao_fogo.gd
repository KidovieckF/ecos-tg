extends UpgradeData
class_name UpgradeExplosao

var cena_visual = preload("res://Cenas/Efeitos/explosao_Effect.tscn")

func ao_inimigo_morrer(inimigo, player):
	var meu_hurtbox = inimigo.get_node_or_null("Hurtbox")
	if meu_hurtbox == null or not meu_hurtbox.has_node("Queimadura"):
		print("QUEIMANDO")
		
	var raio_explosao = 150.0
	var forca_empurrao = 50.0
	
	var dano_explosao = valor
		
	
	var todos_inimigos = inimigo.get_tree().get_nodes_in_group("Inimigos")
	for outro_inimigo in todos_inimigos:
		var outro_hurtbox = outro_inimigo.get_node_or_null("Hurtbox")
		if outro_inimigo != inimigo:
			var distancia = inimigo.global_position.distance_to(outro_inimigo.global_position)
			
			if distancia <= raio_explosao:
				var direcao = (outro_inimigo.global_position - inimigo.global_position).normalized()
				outro_inimigo.global_position += direcao * forca_empurrao
				
				if outro_hurtbox and outro_hurtbox.has_method("take_damage"):
					outro_hurtbox.take_damage(dano_explosao, Color.ORANGE, false)
					
	var desenho = cena_visual.instantiate()
	

	inimigo.get_parent().add_child(desenho)
	desenho.scale *= 3

	desenho.global_position = inimigo.global_position
	
	print("KABOOM! Explosão de queimadura causou ", dano_explosao, " de dano!")
