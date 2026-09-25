extends Node2D

var timer = 0.0


var tempo_entre_terremotos = 0.5 

func _process(delta):

	var arma = RunData.armas[0] 
	var player = get_parent()
	var mundo = player.get_parent()
	
	if not arma.tem_efeito("terremoto_passos"):
		queue_free()
		return
		

	if player.velocity != Vector2.ZERO:
		timer -= delta
		

		if timer <= 0:
			_spawnar_terremoto(arma, player, mundo)
			timer = tempo_entre_terremotos

func _spawnar_terremoto(arma, player, mundo):

	var chao = arma.projetil.instantiate()
	
	mundo.add_child(chao)

	chao.global_position = player.global_position 
	

	var is_critico = arma.calcular_critico()
	var dano_atual = arma.dano
	if is_critico: dano_atual *= RunData.dano_critico
	dano_atual = (dano_atual + arma.dano_add + RunData.dano_adicional) * RunData.dano_multiplicador
	
	var direcao = Vector2.ZERO 
	
	chao.start(dano_atual, is_critico)
	
	for upgrade in arma.upgrades_ativos:
		if upgrade.has_method("ao_atirar"): 
			upgrade.ao_atirar(player, direcao, chao)
