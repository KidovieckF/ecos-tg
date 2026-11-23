extends Node2D

var portas_da_sala = []
var contador_inimigos = 0
var sensor_ja_ativado = false
var tempo_de_vida = 0
var lista_inimigos = []
var round_atual = 1
var round_maximo = 3
var inimigo = preload("res://Cenas/Inimigos/inimigo_base.tscn")
var player
var processando_onda = false
var sala_limpa = false
var dificuldade = 1

var tempo_restante_onda: float = 0.0
var onda_ativa: bool = false

var grupo_id: int = 0
var eh_mestre: bool = true
var sala_mestre: Node2D = null
var celulas_do_grupo: Array[Node2D] = []

@export var tipos_inimigos : Array[inimigo_data]
var tipos_restantes_na_sala: Array[inimigo_data] = []


func _ready() -> void:
	round_maximo = randi_range(2, 4)
	if RunData.andar == 1 and has_node("Chao"):
		espalhar_flores_aleatorias()

func _physics_process(delta: float) -> void:
	tempo_de_vida += delta
	
	if onda_ativa and not sala_limpa and not processando_onda:
		if round_atual < round_maximo:
			tempo_restante_onda -= delta
			if tempo_restante_onda <= 0.0:
				print("⏰ TEMPO ESGOTOU! Nova onda chegando sobre os sobreviventes! (Restam: ", contador_inimigos, ")")
				avancar_onda_por_tempo()

func espalhar_flores_aleatorias() -> void:
	var catalogo_flores = [
		{ "source": 4, "coords": Vector2i(0, 0) }, 
		{ "source": 5, "coords": Vector2i(0, 0) }, 
		{ "source": 6, "coords": Vector2i(0, 0) }, 
		{ "source": 7, "coords": Vector2i(0, 0) }, 
	]
	
	var chance_flor = 0.08
	var chao_node = get_node_or_null("Chao")
	if chao_node:
		for celula in chao_node.get_used_cells():
			if randf() < chance_flor:
				var flor = catalogo_flores.pick_random()
				chao_node.set_cell(celula, flor.source, flor.coords)

func obter_tempo_limite_onda() -> float:
	var tempo = 30.0 - (RunData.dificuldade - 1) * (15.0 / 9.0)
	return clamp(tempo, 12.0, 30.0)

func _on_area_2d_body_entered(body: Node2D) -> void:
	inicar_sala(body)

func inicar_sala(body):
	if not eh_mestre and is_instance_valid(sala_mestre):
		sala_mestre.inicar_sala(body)
		return
		
	if sensor_ja_ativado == false and tempo_de_vida > 0.5:
		if body.is_in_group("Players"):
			sensor_ja_ativado = true
			RunData.dificuldade += dificuldade
			print("Dificuldade atual da Run: ", RunData.dificuldade)
			
			# Fecha as portas de TODAS as células da macro-sala
			fechar_todas_as_portas()
			
			player = body
			await get_tree().create_timer(0.8, false).timeout
			await chamar_onda()
func fechar_todas_as_portas() -> void:
	if not eh_mestre and is_instance_valid(sala_mestre):
		sala_mestre.fechar_todas_as_portas()
		return
		
	var celulas = celulas_do_grupo if celulas_do_grupo.size() > 0 else [self]
	for c in celulas:
		if is_instance_valid(c):
			c.sensor_ja_ativado = true
			if "portas_da_sala" in c:
				for p in c.portas_da_sala:
					if is_instance_valid(p):
						p.fechar_porta()
func abrir_todas_as_portas() -> void:
	if not eh_mestre and is_instance_valid(sala_mestre):
		sala_mestre.abrir_todas_as_portas()
		return
	
	var celulas = celulas_do_grupo if celulas_do_grupo.size() > 0 else [self]
	for c in celulas:
		if is_instance_valid(c):
			c.sala_limpa = true
			c.sensor_ja_ativado = true
			if "portas_da_sala" in c:
				for p in c.portas_da_sala:
					if is_instance_valid(p):
						p.abrir_porta()
func verifica_inimigos():
	if sala_limpa or processando_onda:
		return
		
	lista_inimigos = lista_inimigos.filter(func(i): return is_instance_valid(i) and not i.is_queued_for_deletion())
	contador_inimigos = lista_inimigos.size()
	
	if contador_inimigos == 0:
		if round_atual < round_maximo:
			onda_ativa = false
			round_atual += 1
			print("Onda limpa com agilidade! Próxima onda em 2 segundos...")
			await get_tree().create_timer(2.0, false).timeout
			await chamar_onda()
		else:
			onda_ativa = false
			sala_limpa = true
			RunData.consumir_carga_pocoes()
			abrir_todas_as_portas()
			print("SALA LIMPA! Todas as portas do grupo abertas.")

func escolher_tipo_da_onda() -> inimigo_data:
	var tipos_validos = tipos_inimigos.filter(func(tipo): 
		return tipo.dificuldade_minima <= RunData.dificuldade
	)
	if tipos_validos.is_empty():
		tipos_validos = tipos_inimigos

	if tipos_validos.is_empty():
		return null

	if tipos_restantes_na_sala.is_empty():
		tipos_restantes_na_sala = tipos_validos.duplicate()
		tipos_restantes_na_sala.sort_custom(func(a, b): return a.peso_spawn > b.peso_spawn)

	return tipos_restantes_na_sala.pop_front()

func calcular_quantidade_inimigos(tipo: inimigo_data) -> int:
	var peso = tipo.peso_spawn if "peso_spawn" in tipo else 30
	var qtd_base: float = 0.0

	if peso >= 60:
		qtd_base = randf_range(14.0, 18.0) 
	elif peso >= 35:
		qtd_base = randf_range(8.0, 11.0)  
	elif peso >= 15:
		qtd_base = randf_range(5.0, 7.0)   
	else:
		qtd_base = randf_range(3.0, 4.0)   

	var mult_round = 1.0 + (round_atual - 1) * 0.15
	var total = qtd_base * mult_round

	if celulas_do_grupo.size() > 1:
		total *= (1.0 + (celulas_do_grupo.size() - 1) * 0.5)

	return max(1, int(round(total)))

func chamar_onda():
	processando_onda = true
	
	var tipo_da_onda = escolher_tipo_da_onda()
	if tipo_da_onda == null:
		processando_onda = false
		return
		
	var qtd_total = calcular_quantidade_inimigos(tipo_da_onda)
	tempo_restante_onda = obter_tempo_limite_onda()
	print(">>> ONDA ", round_atual, "/", round_maximo, ": ", qtd_total, "x ", tipo_da_onda.Nome, " | Tempo limite: ", "%.1f" % tempo_restante_onda, "s")

	var restantes = qtd_total
	while restantes > 0:
		var spawn_agora = 2 if restantes >= 2 and qtd_total >= 8 else 1
		for i in range(spawn_agora):
			instanciar_inimigo(tipo_da_onda)
		restantes -= spawn_agora
		
		var delay = 0.5 if qtd_total >= 8 else 0.8
		await get_tree().create_timer(delay, false).timeout

	processando_onda = false
	onda_ativa = true
	verifica_inimigos()

func avancar_onda_por_tempo():
	if processando_onda or round_atual >= round_maximo or sala_limpa:
		return
	onda_ativa = false
	round_atual += 1
	chamar_onda()

func instanciar_inimigo(data_sorteado: inimigo_data):
	var cena_a_instanciar = data_sorteado.cena_inimigo if data_sorteado.cena_inimigo else inimigo
	var novo_inimigo = cena_a_instanciar.instantiate()
	
	var celula_escolhida = celulas_do_grupo.pick_random() if celulas_do_grupo.size() > 0 else self
	var rand_x = randf_range(50, 1000)
	var rand_y = randf_range(40, 590)
	novo_inimigo.position = Vector2(rand_x, rand_y)
	novo_inimigo.player = player
	novo_inimigo.data = data_sorteado
	celula_escolhida.add_child(novo_inimigo)

	lista_inimigos.append(novo_inimigo)
	
	novo_inimigo.morreu.connect(verifica_inimigos)
	novo_inimigo.morreu.connect(func():
		player.ganhar_xp(novo_inimigo.data.exp)
	)

func ajustar_parede(norte, sul, leste, oeste):
	if norte: $ParedeNorte.clear()
	if sul: $ParedeSul.clear()
	if leste: $ParedeLeste.clear()
	if oeste: $ParedeOeste.clear()

func abrir_divisoria_macro(norte, sul, leste, oeste):
	if norte:
		$ParedeNorte.clear()
		$PortaNorte.clear()
	if sul:
		$ParedeSul.clear()
		$PortaSul.clear()
	if leste:
		$ParedeLeste.clear()
		$PortaLeste.clear()
	if oeste:
		$ParedeOeste.clear()
		$PortaOeste.clear()
