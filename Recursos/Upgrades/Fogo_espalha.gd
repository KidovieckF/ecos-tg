extends UpgradeData
class_name UpgradeFogoEspalha

var cena_da_queimadura = preload("res://Cenas/Player/Magias/Debuffs/Queimadura.tscn")

func ao_inimigo_morrer(inimigo, player):
	print("Espalhou")
	var ini_hurtbox = inimigo.get_node_or_null("Hurtbox")
	var queimadura_morta = ini_hurtbox.get_node_or_null("Queimadura")
	if not queimadura_morta:
		print("não tem queimadura")
		return 
		
	var dano_base_fogo = queimadura_morta.dano_final
	var limite = queimadura_morta.limite_stacks
	var stacks_para_passar = queimadura_morta.stacks
	var inimigo_mais_proximo = _achar_inimigo_mais_proximo(inimigo)
	
	if inimigo_mais_proximo != null:
		var queimadura_nova = inimigo_mais_proximo.get_node_or_null("Queimadura")
		if not queimadura_nova:
			queimadura_nova = cena_da_queimadura.instantiate()
			queimadura_nova.name = "Queimadura"
			queimadura_nova.limite_stacks = limite
			inimigo_mais_proximo.add_child(queimadura_nova)
			for i in range(stacks_para_passar):
				queimadura_nova.adicionar_stacks(limite, dano_base_fogo)
				
				
func _achar_inimigo_mais_proximo(morto):
	var menor_dist = 1000
	var alvo = null
	
	for ini in morto.get_tree().get_nodes_in_group("Inimigos"):
		if is_instance_valid(ini) and ini != morto: 
			var dist = morto.global_position.distance_to(ini.global_position)
			if dist < menor_dist:
				menor_dist = dist
				alvo = ini
	return alvo
