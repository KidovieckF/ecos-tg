extends ArmaRecurso
class_name MissilMagico


var cooldown = 0
var tiros_por_burst = 1
var bursts = 1
var speed_calculada = 200
var tamanho = Vector2(1,1)
var bounces = 0
var penetracao = false
var dano_add = 0
var tem_orbital = false

func calcular_critico() -> bool:
	return randi_range(1, 100) <= RunData.chance_critico


func calcular_upgrades():
	tiros_por_burst = 1
	bursts = 1
	speed_calculada = 200
	tamanho = Vector2(1,1)
	bounces = 0
	dano_add = 0
	penetracao = false
	tem_orbital = false
	
	print("Teste")
	for i in upgrades_ativos:
		if i.efeito == "MultiDisparos":
			bursts += i.valor
		if i.efeito == "Dano":
			dano_add += i.valor
		if i.efeito == "velocidade":
			speed_calculada += i.valor
		if i.efeito == "+1Disparo":
			tiros_por_burst += i.valor
		if i.efeito == "tamanho":
			tamanho *= i.valor
		if i.efeito == "bounce":
			bounces += i.valor
		if i.efeito == "penetracao":
			penetracao = true
		if i.efeito == "missil_orbital":
			tem_orbital = true
			
	RunData.aplicar_modificadores_globais(self)
	

func disparar_burst(player, dano_adicional, dano_multiplicador, proj_por_burst,direcao):
	for i in range(proj_por_burst):
		var dano_atual = dano
		var is_critico = calcular_critico()
		if is_critico:
			dano_atual *= RunData.dano_critico
		dano_atual += dano_add #upgrades
		print("Dano atual: ", dano_atual)
		dano_atual += dano_adicional #artefatos
		print("Dano dentro da arma antes do mult: ", dano_atual)
		dano_atual *= dano_multiplicador #artefatos
		print("Dano dentro da arma: ", dano_atual)
		var novo_missil = projetil.instantiate()
		novo_missil.scale *= tamanho  * RunData.mult_tamanho
		player.get_parent().add_child(novo_missil)
		novo_missil.global_position = player.global_position
		novo_missil.start(dano_atual, speed_calculada, proj_por_burst, i, bounces, penetracao, direcao, is_critico)
		
		#Upgrades
		for upgrade in upgrades_ativos:
			if upgrade.has_method("ao_atirar"):
				upgrade.ao_atirar(player, direcao, novo_missil)
			if upgrade.efeito == "missil_explosao":
				print("entrou aqui")
				novo_missil.get_node("Area2D").area_entered.connect(func(area):
					if area.has_method("take_damage"):
						print("aqui tambem")
						upgrade.ao_causar_dano(area, dano_atual, novo_missil)
				)
		

func usar_arma(player, delta, dano_adicional, dano_multiplicador, direcao):
	if tem_orbital:
		return
	print("atirei")
	var intervalo = 0.08
	for idx in range(bursts):
		if RunData.tiro_pela_culatra:
			direcao = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if idx == 0:
			disparar_burst(player, dano_adicional, dano_multiplicador, tiros_por_burst, direcao)
		else:
			var timer = player.get_tree().create_timer(idx * intervalo)
			timer.timeout.connect(func():
				disparar_burst(player, dano_adicional, dano_multiplicador, tiros_por_burst, direcao)
			)
	player.get_node("AttackTimer").start()
	
func parar_uso(player):
	pass
