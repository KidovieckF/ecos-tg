extends Node

const ANDARES_MAXIMOS = 3

signal inventario_atualizado


#Cenas Artefatos
var cena_Iha_artefato = preload("res://Cenas/Artefatos/IHA_artefato.tscn")
var cena_egide = preload("res://Cenas/Artefatos/Egide.tscn")

# Sinais dos artefatos
signal sinal_dano_causado(dano_recebido, posicao_do_inimigo)
signal sinal_critico(dano_recebido, posicao_do_inimigo)
signal sinal_dano_queimadura(dano_recebido, inimigo_alvo)
signal sinal_egide_morreu()


var tela_pause_atual = null

var tela_debug_atual = null

var armas: Array[ArmaRecurso] = [null, null]

var andar := 1
var moeda_run := 0
var arma_escolhida: ArmaRecurso

var jogador_parado : bool = false
var tempo_parado : float = 0.0

var artefatos_coletados : Array[Artefato_data] = []
var personagem_base: player_data

#Vars dos artefatos
var tiro_pela_culatra = false
var cristal_corrompido = false
var prensa_hidraulica = false
var cura_parado_total = 0.0
var tempo_cura_acumulado : float = 0.0
var cura_queimadura_total = 0.0

#Egide
var egides_ativas : Array[Node] = [] 
var egides_totais = 0
var recarregando_egide = false



#Cowboy
var chapeus_coletados = 0
var fila_de_tiros_chapeu : Array[Vector2] = []
var chapeu_atirando = false

var speed_ao_critar_total = 0.0
var speed_bonus_temporario = 0.0


var mult_de_atk_speed
var speed_calculado: float = 300.0
var vida_max := 0.0
var vida_atual := 0.0
var xp_atual := 0.0
var barra_exp := 0.0
var nivel := 1
var dano_adicional := 0
var dano_multiplicador = 1
var dificuldade = 1
var mult_dificuldade = 1 + (dificuldade * 0.05)
var gamemode = "Mouse"
var barra_ultimate := 0
var barra_ultimate_atual := 0
var chance_critico = 50
var dano_critico = 1.5
var dano_reducao = 0
var mult_tamanho = 1

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	sinal_critico.connect(_ativar_boost_botina)
	sinal_dano_queimadura.connect(_ativar_cura_fogo)
	sinal_critico.connect(_ativar_chapeu_cowboy)
	sinal_egide_morreu.connect(_iniciar_recarga_egide) 


func _process(delta: float) -> void:
	if fila_de_tiros_chapeu.size() > 0 and chapeu_atirando == false:
		chapeu_atirando = true
		var alvo_posicao = fila_de_tiros_chapeu.pop_front()
		var player = get_tree().get_first_node_in_group("Players")
		print(player)
		if player != null:
			var nova_bala = cena_Iha_artefato.instantiate()
			player.get_parent().add_child(nova_bala)
			
			nova_bala.global_position = player.global_position
			var direcao_tiro = (alvo_posicao - player.global_position).normalized()
			if nova_bala.has_method("start"):
				nova_bala.start(player.global_position, direcao_tiro, 10, 900)

			
		print("IHAAAA! Tiro disparado! Faltam na fila: ", fila_de_tiros_chapeu)
		
		await get_tree().create_timer(0.1).timeout
		chapeu_atirando = false
		
func _unhandled_input(event):
	if event.is_action_pressed("Debbug"):
		var arvore = get_tree()
		if arvore.paused:
			arvore.paused = false
			if is_instance_valid(tela_debug_atual):
				tela_debug_atual.queue_free()
		else:
			arvore.paused = true
			tela_debug_atual = preload("res://Cenas/Huds/Debugg_Hud.tscn").instantiate()
			# Adiciona a tela de pause na raiz do jogo
			arvore.root.add_child(tela_debug_atual) 
	
	if event.is_action_pressed("Pause"):
		var arvore = get_tree()
		if arvore.paused:
			arvore.paused = false
			if is_instance_valid(tela_pause_atual):
				tela_pause_atual.queue_free()
		else:
			arvore.paused = true
			tela_pause_atual = preload("res://Cenas/Huds/hud_pause.tscn").instantiate()
			# Adiciona a tela de pause na raiz do jogo
			arvore.root.add_child(tela_pause_atual) 

func calcular_artefatos():
	var dano = 0
	var vida = personagem_base.vida
	var speed = personagem_base.speed
	var chance_crit_add = 0
	var mult = 1
	var vida_mult = 1
	var speed_mult = 1
	var atk_speed_mult = 1
	var reducao_dano = 0
	var tamanho_mult = 1
	
	
	var soma_cura_flor = 0.0
	var soma_speed_critar = 0
	var soma_oculos = 0.0
	var soma_chapeus = 0
	var soma_egides = 0
	
	var tem_culatra = false
	var tem_cristal = false
	var tem_prensa = false
	
	for i in artefatos_coletados:
		dano += i.dano_add
		vida += i.vida_max_add
		speed += i.speed_add 
		mult += i.dano_mult
		
		soma_oculos += i.cura_queimadura_pct
		soma_cura_flor += i.cura_parado 
		soma_chapeus += i.tem_chapeu
		soma_egides += i.tem_egide
		
		chance_crit_add += i.chance_critico_add
		vida_mult += i.vida_max_mult
		speed_mult += i.speed_mult
		atk_speed_mult += i.atk_speed_mult
		tamanho_mult += i.tamanho_magia_mult
		reducao_dano += i.reducao_dano
		soma_speed_critar += i.speed_ao_critar
		
		if i.tiro_pela_culatra == true:
			tem_culatra = true
		if i.cristal_corrompido == true:
			tem_cristal = true
		if i.prensa_hidraulica == true:
			tem_prensa = true
		
	tiro_pela_culatra = tem_culatra
	prensa_hidraulica = tem_prensa
	cristal_corrompido = tem_cristal
	
	chapeus_coletados = soma_chapeus
	egides_totais = soma_egides
	cura_queimadura_total = soma_oculos
	speed_ao_critar_total = soma_speed_critar


	while egides_ativas.size() < egides_totais:
		_spawnar_egide()

	if cristal_corrompido == true:
		vida /= 2

	speed_mult = max(0.2, speed_mult)
	speed *= speed_mult
	vida *= vida_mult
	cura_parado_total = soma_cura_flor
	mult_tamanho = tamanho_mult
	dano_reducao = reducao_dano
	dano_adicional = dano
	vida_max = vida
	speed_calculado = speed
	dano_multiplicador = mult
	chance_critico = 50 + chance_crit_add
	mult_de_atk_speed = atk_speed_mult
	
func aplicar_efeitos_parado(player, delta):
	# ITEM 10: Plantinha Fofinha
	if cura_parado_total > 0:
		tempo_cura_acumulado += delta
		if tempo_cura_acumulado >= 1.0:
			var cura = (vida_max * 0.01) * cura_parado_total
			player.curar(cura)
			print("Curou: " + str(cura))
			tempo_cura_acumulado = 0.0

func aplicar_modificadores_globais(arma):
	if prensa_hidraulica:
		var tiros_perdidos = (arma.bursts - 1) + (arma.tiros_por_burst - 1)
		arma.tiros_por_burst = 1
		arma.bursts = 1
		if tiros_perdidos > 0:
			arma.dano_add += (tiros_perdidos * 10)

func adicionar_artefato(artefato : Artefato_data):
	var vida_max_antiga = vida_max 
	
	artefatos_coletados.append(artefato)
	inventario_atualizado.emit()
	artefato.efeito()
	calcular_artefatos()
	
	var diferenca = vida_max - vida_max_antiga
	
	if diferenca > 0:
		vida_atual += diferenca
	
	if vida_atual > vida_max:
		vida_atual = vida_max


func multiplicar_dificuldade() -> float:
	return 1.0 + dificuldade * 0.05

func iniciar_run(personagem: player_data, p_arma: ArmaRecurso) -> void:
	resetar_run()
	
	andar = 1
	
	arma_escolhida = p_arma
	armas[0] = arma_escolhida.duplicate()
	barra_ultimate = armas[0].barra_ultimate
	vida_max = personagem.vida
	vida_atual = personagem.vida
	barra_exp = personagem.exp_bar
	speed_calculado = personagem.speed
	personagem_base = personagem
	artefatos_coletados.clear()
	calcular_artefatos()
	

func resetar_run() -> void:
	andar = 1
	moeda_run = 0
	arma_escolhida = null
	vida_max = 0
	vida_atual = 0
	mult_de_atk_speed = 1
	chance_critico = 10
	dano_critico = 1.5
	xp_atual = 0
	barra_exp = 0
	nivel = 1
	dano_adicional = 0
	dano_multiplicador = 1
	barra_ultimate_atual = 0
	dificuldade = 1

func guardar_player(player) -> void:
	xp_atual = player.xp_atual
	barra_exp = player.barra_exp
	nivel = player.nivel

func carregar_player(player) -> void:
	player.xp_atual = xp_atual
	player.barra_exp = barra_exp
	player.nivel = nivel
	player.arma = arma_escolhida

func avancar_andar():
	andar += 1


#EFEITOS DOS ARTEFATOS!!!!

func _ativar_boost_botina(dano, pos):

	if speed_ao_critar_total > 0:
		print("BOOST ATIVADO COM SUCESSO!")
		speed_bonus_temporario = speed_ao_critar_total
		
		# Como o RunData é um Node, podemos usar o timer normal em paz:
		await get_tree().create_timer(2.0).timeout
		
		speed_bonus_temporario = 0.0

func _ativar_cura_fogo(dano_recebido, inimigo):

	if cura_queimadura_total > 0:
		print("Ativou")
		# Multiplica o dano da queimadura pela sua porcentagem de cura
		var cura_calculada = dano_recebido * cura_queimadura_total
		
		# Procura o Player na tela
		var player = get_tree().get_first_node_in_group("Players")
		
		# Se o player estiver vivo e na tela, manda curar!
		if player != null:
			player.curar(cura_calculada)

func _ativar_chapeu_cowboy(dano_recebido, posicao_inimigo):
	print("Ihaa")
	if chapeus_coletados > 0:
		for i in range(chapeus_coletados):
			fila_de_tiros_chapeu.append(posicao_inimigo)
			
#EGIDE:
func _iniciar_recarga_egide():
	# Se a "fábrica" já está trabalhando, ignora o sinal e deixa ela trabalhar
	if recarregando_egide == true:
		return 
		
	recarregando_egide = true
	
	# A fábrica continua trabalhando 1 por 1 até repor todos os escudos perdidos!
	while egides_ativas.size() < egides_totais:
		await get_tree().create_timer(10.0).timeout
		_spawnar_egide()
		
	# Terminou de repor todos? Desliga a fábrica.
	recarregando_egide = false
	
func _spawnar_egide():
	var player = get_tree().get_first_node_in_group("Players")
	if player == null: return
		
	# Spawna apenas UM escudo (tiramos o while daqui e passamos lá pra cima)
	var instancia_egide = cena_egide.instantiate()
	player.get_parent().add_child(instancia_egide)
	instancia_egide.global_position = player.global_position
	
	egides_ativas.append(instancia_egide)
	
	if instancia_egide.has_method("start"):
		instancia_egide.start(player.global_position, 5.0, 300)

	
	
	
