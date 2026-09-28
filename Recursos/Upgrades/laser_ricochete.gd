extends UpgradeData
class_name UpgradeLaserRicochete

func ao_causar_dano(inimigo, dano, projetil):
	var arma = RunData.armas[0]
	
	if arma.bounces <= 0:
		return
	var bounces_restantes = arma.bounces
	var inimigo_atual = inimigo
	var ignorar_lista = [inimigo.owner] # Anota quem já tomou choque
	
	while bounces_restantes > 0:
		var proximo_alvo = _achar_inimigo_mais_proximo(inimigo_atual, ignorar_lista)
		
		if proximo_alvo == null:
			break 
			
		_desenhar_linha_ricochete(inimigo_atual, proximo_alvo)
		
		var hurtbox = proximo_alvo.get_node_or_null("Hurtbox")
		if hurtbox:
			hurtbox.take_damage(dano, Color.CYAN, false)
			
		ignorar_lista.append(proximo_alvo)
		inimigo_atual = hurtbox # Prepara o próximo pulo
		bounces_restantes -= 1


func _achar_inimigo_mais_proximo(hurtbox_origem, ignorar_lista):
	var menor_dist = 400.0 
	var alvo = null
	
	var monstro_origem = hurtbox_origem.owner 
	
	for ini in hurtbox_origem.get_tree().get_nodes_in_group("Inimigos"):
		
		if is_instance_valid(ini) and not (ini in ignorar_lista): 
			
			if "morto" in ini and ini.morto:
				continue
				
			var dist = monstro_origem.global_position.distance_to(ini.global_position)
			if dist < menor_dist:
				menor_dist = dist
				alvo = ini
				
	return alvo

func _desenhar_linha_ricochete(de_onde, para_onde):
	var linha = Line2D.new()
	linha.width = 4.0
	linha.default_color = Color.CYAN 
	linha.z_index = 5 
	linha.add_point(de_onde.global_position)
	linha.add_point(para_onde.global_position)
	de_onde.get_tree().current_scene.add_child(linha)
	
	var timer = de_onde.get_tree().create_timer(0.2)
	timer.timeout.connect(linha.queue_free)
