extends UpgradeData
class_name UpgradeMissil_Bomba

var cena_explosao = preload("res://Cenas/Efeitos/missil_explosao.tscn")

func ao_causar_dano(area_atingida, dano, projetil):
	var explosao = cena_explosao.instantiate()
	projetil.get_parent().add_child(explosao)
	explosao.global_position = projetil.global_position
	
	var raio_explosao = 120.0
	var dano_explosao = valor 
	
	
	var todos_inimigos = projetil.get_tree().get_nodes_in_group("Inimigos")
	for outro_inimigo in todos_inimigos:
		if is_instance_valid(outro_inimigo):
			
			# Calcula a distância da explosão para o inimigo
			var distancia = projetil.global_position.distance_to(outro_inimigo.global_position)
			
			if distancia <= raio_explosao:
				# Pega o Hurtbox dele com segurança (igual fizemos na queimadura!)
				var outro_hurtbox = outro_inimigo.get_node_or_null("Hurtbox")
				if outro_hurtbox and outro_hurtbox.has_method("take_damage"):
					outro_hurtbox.take_damage(dano_explosao, Color.ORANGE, false)
					
	print("BOOM! Míssil causou ", dano_explosao, " de dano em área!")
