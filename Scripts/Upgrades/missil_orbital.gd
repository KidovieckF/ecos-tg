extends Node2D

var timer_reload = 0.0
var timer_tiro = 0.0
var raio_hover = 60.0
var misseis_carregados = []

func _process(delta):
	var arma = RunData.armas[0]
	var player = get_parent()
	
	if arma.nome == "Missil" and not arma.tem_orbital:
		queue_free()
		return
		
	var total_misseis = arma.tiros_por_burst * arma.bursts
	

	if misseis_carregados.size() < total_misseis:
		timer_reload -= delta
		if timer_reload <= 0:
			_spawnar_um_missil()
			var tempo_total = player.personagem.atk_cd / RunData.mult_de_atk_speed + 10
			timer_reload = tempo_total / total_misseis
			
	
	timer_tiro -= delta
	if timer_tiro <= 0 and misseis_carregados.size() > 0:
		var inimigo = _achar_inimigo()
		if inimigo:
			_atirar_um_missil(inimigo)
			timer_tiro = 0.1 # <-- Mude aqui para alterar a cadência de fogo entre os mísseis
			
	# 3. ORGANIZADOR VISUAL
	# Atualiza a posição de todo mundo nas suas costas para ficarem bonitos
	_atualizar_posicoes()

func _spawnar_um_missil():
	var arma = RunData.armas[0]
	var missil_real = arma.projetil.instantiate()
	
	missil_real.set_physics_process(false)
	missil_real.get_node("Area2D").monitoring = false
	
	# Faz ele nascer invisível no centro para o lerp empurrar ele pra fora bonito
	missil_real.position = Vector2.ZERO 
	
	add_child(missil_real)
	misseis_carregados.append(missil_real)

func _atirar_um_missil(inimigo):
	var arma = RunData.armas[0]
	var player = get_parent()
	var mundo = player.get_parent()
	
	# Puxa a primeira bala da sua asa e arranca ela da lista
	var missil = misseis_carregados.pop_front()
	var direcao_exata = (inimigo.global_position - missil.global_position).normalized()
	
	var pos_salva = missil.global_position
	remove_child(missil)
	mundo.add_child(missil)
	missil.global_position = pos_salva
	
	var is_critico = arma.calcular_critico()
	var dano_atual = arma.dano
	if is_critico: dano_atual *= RunData.dano_critico
	dano_atual = (dano_atual + arma.dano_add + RunData.dano_adicional) * RunData.dano_multiplicador
	
	missil.start(dano_atual, arma.speed_calculada + 500, 1, 0, arma.bounces, arma.penetracao, direcao_exata, is_critico)
	missil.set_physics_process(true)
	missil.get_node("Area2D").set_deferred("monitoring", true)
	
	for upgrade in arma.upgrades_ativos:
		if upgrade.has_method("ao_atirar"): upgrade.ao_atirar(player, direcao_exata, missil)
		if upgrade.efeito == "missil_explosao":
			missil.get_node("Area2D").area_entered.connect(func(area):
				if area.has_method("take_damage"): upgrade.ao_causar_dano(area, dano_atual, missil)
			)

func _atualizar_posicoes():
	var qtd_atual = misseis_carregados.size()
	if qtd_atual == 0: return
	
	var espacamento = PI / (qtd_atual + 1)
	
	for i in range(qtd_atual):
		var missil = misseis_carregados[i]
		var angulo_atual = PI + (espacamento * (i + 1))
		
		# Onde o míssil deveria estar
		var pos_alvo = Vector2(cos(angulo_atual), sin(angulo_atual)) * raio_hover
		
		# Usa Lerp para deslizar os mísseis suavemente pelo ar até a nova posição
		missil.position = missil.position.lerp(pos_alvo, 0.15)
		missil.rotation = angulo_atual + (PI/2)

func _achar_inimigo():
	var menor_dist = 400.0
	var alvo = null
	for ini in get_tree().get_nodes_in_group("Inimigos"):
		if is_instance_valid(ini):
			var dist = global_position.distance_to(ini.global_position)
			if dist < menor_dist:
				menor_dist = dist
				alvo = ini
	return alvo
