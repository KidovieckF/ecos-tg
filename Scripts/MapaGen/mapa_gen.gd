extends Node

@export var player: CharacterBody2D
@export var total_salas_alvo: int = 14
var inimigo = preload("res://Cenas/Inimigos/inimigo_base.tscn")
var salas_andar1 = [ preload("res://Cenas/Mundo/Salas/sala_base.tscn")] #preload("res://Cenas/Mundo/Salas/sala_2.tscn", preload("res://Cenas/Mundo/Salas/sala_1.tscn")  ]
var salas_andar2 = [ preload("res://Cenas/Mundo/Salas/sala_base2.tscn")]
var sala_boss =  preload("res://Cenas/Mundo/Salas/sala_boss.tscn")
var sala_miniboss = preload("res://Cenas/Mundo/Salas/sala_baseMinboss.tscn")
var porta = preload("res://Cenas/Mundo/Salas/Porta.tscn")
var loja = preload("res://Cenas/Mundo/Salas/sala_loja.tscn")
var room_altura = 641
var room_largura = 1139
var room_size = Vector2(room_largura,room_altura)
var salas_possiveis = {}
var salas_criadas = {}

var pity = 0
var loja_criada = false
var proximo_grupo_id: int = 1
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	AudioManager.tocar_musica(AudioManager.BGM_FASE)
	if RunData.andar == 1:
		salas_possiveis = salas_andar1.duplicate()
	elif RunData.andar == 2:
		salas_possiveis = salas_andar2.duplicate()
		
	generate_level()
	player.trocar_camera()
	
	if RunData.dados_restauracao_mapa.size() > 0:
		restaurar_estado_do_mapa()
	else:
		configurar_entrada_e_animacao()

func restaurar_estado_do_mapa() -> void:
	var dados = RunData.dados_restauracao_mapa
	RunData.dados_restauracao_mapa = {}
	
	var pos_x = dados.get("player_pos_x", room_size.x / 2)
	var pos_y = dados.get("player_pos_y", room_size.y / 2)
	player.global_position = Vector2(pos_x, pos_y)
	player.set_physics_process(true)
	
	await get_tree().process_frame
	
	var salas_limpas_lista = dados.get("salas_limpas", [])
	for item in salas_limpas_lista:
		var coord = Vector2i(item["x"], item["y"])
		if salas_criadas.has(coord):
			var sala = salas_criadas[coord]
			sala.sala_limpa = true
			sala.sensor_ja_ativado = true
			# Abre todas as portas dessa sala
			if sala.has_method("abrir_todas_as_portas"):
				sala.abrir_todas_as_portas()
			elif "portas_da_sala" in sala:
				for p in sala.portas_da_sala:
					if is_instance_valid(p):
						p.abrir_porta()
						
	print(">>> MAPA RESTAURADO: Player na posição ", player.global_position, " | Salas limpas: ", salas_limpas_lista.size())
	
func configurar_entrada_e_animacao():
	var sala_inicial = salas_criadas[Vector2i(0, 0)]
	
	if sala_inicial.has_node("ParedeOeste"):
		sala_inicial.get_node("ParedeOeste").clear()
		
	criar_barreira_retorno(sala_inicial)
	
	player.set_physics_process(false)
	player.global_position = Vector2(-80, room_size.y / 2)
	
	var sprite_player = player.get_node("Sprite2D")
	sprite_player.flip_h = false
	sprite_player.play("AndandoLado")
	
	var tween = create_tween()
	var pos_centro = room_size / 2
	tween.tween_property(player, "global_position", pos_centro, 2.0)
	
	tween.tween_callback(func():
		sprite_player.play("IdleLado")
		player.set_physics_process(true)
		
		sala_inicial.inicar_sala(player)
	)
func criar_barreira_retorno(sala):

	var barreira = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, room_size.y)
	col.shape = shape
	barreira.add_child(col)
	

	barreira.position = Vector2(0, room_size.y / 2)
	barreira.collision_layer = 1
	barreira.collision_mask = 2
	sala.add_child(barreira)


func _process(delta: float) -> void:
	pass



func generate_level():
	salas_criadas.clear()
	loja_criada = false
	pity = 0
	proximo_grupo_id = 1
	
	var miniboss_criado = false
	
	var sala_sorteada_inicial = salas_possiveis.pick_random()
	criar_sala_no_mapa(sala_sorteada_inicial, Vector2i.ZERO)
	
	var pontas_ativas: Array[Vector2i] = [Vector2i.ZERO]
	var tentativas = 0
	var max_tentativas = 500
	
	while salas_criadas.size() < total_salas_alvo and tentativas < max_tentativas:
		tentativas += 1
		
		if pontas_ativas.is_empty():
			for pos in salas_criadas.keys():
				if not obter_vizinhos_livres(pos).is_empty():
					pontas_ativas.append(pos)
					break
			if pontas_ativas.is_empty():
				break
				
		var index_ponta = randi_range(0, pontas_ativas.size() - 1)
		var ponta_atual = pontas_ativas[index_ponta]
		var vizinhos_livres = obter_vizinhos_livres(ponta_atual)
		
		if vizinhos_livres.is_empty():
			pontas_ativas.remove_at(index_ponta)
			continue
			
		var nova_pos = vizinhos_livres.pick_random()
		
		if not miniboss_criado and salas_criadas.size() >= int(total_salas_alvo * 0.45):
			criar_sala_no_mapa(sala_miniboss, nova_pos)
			miniboss_criado = true
			pontas_ativas.append(nova_pos)
			continue
			
		if not loja_criada and (randf() <= 0.20 or pity >= 3):
			criar_sala_no_mapa(loja, nova_pos)
			loja_criada = true
			continue
			
		if not loja_criada:
			pity += 1
			
		var sala_sorteada = salas_possiveis.pick_random()
		var celulas_alvo = sortear_formato_macro(nova_pos)
		
		if celulas_alvo.size() > 1:
			var g_id = proximo_grupo_id
			proximo_grupo_id += 1
			var primeira_sala: Node2D = null
			
			for c_pos in celulas_alvo:
				if not salas_criadas.has(c_pos):
					var s = criar_sala_no_mapa(sala_sorteada, c_pos)
					s.grupo_id = g_id
					if primeira_sala == null:
						primeira_sala = s
						s.eh_mestre = true
					else:
						s.eh_mestre = false
						s.sala_mestre = primeira_sala
					primeira_sala.celulas_do_grupo.append(s)
					pontas_ativas.append(c_pos)
					
			if primeira_sala != null:
				for s in primeira_sala.celulas_do_grupo:
					s.celulas_do_grupo = primeira_sala.celulas_do_grupo
					s.sala_mestre = primeira_sala
					
			print(">>> MACRO-SALA GERADA: ", celulas_alvo)
		else:
			criar_sala_no_mapa(sala_sorteada, nova_pos)
			pontas_ativas.append(nova_pos)
			
	if not loja_criada:
		garantir_sala_em_ponta_livre(loja)
		loja_criada = true
		
	if not miniboss_criado:
		garantir_sala_em_ponta_livre(sala_miniboss)
		miniboss_criado = true
		
	posicionar_boss_na_maior_distancia()
	
	criar_porta()
	player.position = room_size / 2
	print(">>> MAPA COMPLETO! Total de salas geradas: ", salas_criadas.size())

func criar_sala_no_mapa(cena: PackedScene, pos: Vector2i) -> Node2D:
	var s = cena.instantiate()
	s.global_position = Vector2(pos.x * room_size.x, pos.y * room_size.y)
	get_parent().add_child.call_deferred(s)
	salas_criadas[pos] = s
	return s


func obter_vizinhos_livres(pos: Vector2i) -> Array[Vector2i]:
	var direcoes = [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.UP, Vector2i.LEFT]
	var livres: Array[Vector2i] = []
	for dir in direcoes:
		var v = pos + dir
		if v.x >= 0 and not salas_criadas.has(v):
			livres.append(v)
	return livres


func garantir_sala_em_ponta_livre(cena: PackedScene) -> void:
	for pos in salas_criadas.keys():
		var livres = obter_vizinhos_livres(pos)
		if not livres.is_empty():
			criar_sala_no_mapa(cena, livres.pick_random())
			return


func posicionar_boss_na_maior_distancia() -> void:
	var melhor_pos = Vector2i.ZERO
	var maior_distancia = -1
	
	for pos in salas_criadas.keys():
		var livres = obter_vizinhos_livres(pos)
		for v in livres:
			var dist = abs(v.x) + abs(v.y)
			if dist > maior_distancia:
				maior_distancia = dist
				melhor_pos = v
				
	if melhor_pos != Vector2i.ZERO:
		criar_sala_no_mapa(sala_boss, melhor_pos)
		print(">>> SALA DO BOSS GERADA NA MAIOR DISTÂNCIA: ", melhor_pos, " (Distância: ", maior_distancia, ")")

	
func criar_porta():
	for i in salas_criadas:
		var tem_s = false
		var tem_n = false
		var tem_o = false
		var tem_l = false
		
		var macro_s = false
		var macro_n = false
		var macro_o = false
		var macro_l = false

		var sala_atual = salas_criadas[i]
		var g_atual = sala_atual.grupo_id if "grupo_id" in sala_atual else 0

		if salas_criadas.has(i + Vector2i(1, 0)):
			var sala_vizinha = salas_criadas[i + Vector2i(1, 0)]
			var g_vizinho = sala_vizinha.grupo_id if "grupo_id" in sala_vizinha else 0
			tem_l = true
			if g_atual != 0 and g_atual == g_vizinho:
				macro_l = true
			else:
				var nova_porta = porta.instantiate()
				nova_porta.global_position = Vector2((i.x + 1) * room_largura, (i.y * room_altura) + (room_altura / 2))
				nova_porta.rotation = deg_to_rad(90)
				add_child(nova_porta)
				sala_atual.portas_da_sala.append(nova_porta)
				sala_vizinha.portas_da_sala.append(nova_porta)

		if salas_criadas.has(i + Vector2i(0, 1)):
			var sala_vizinha = salas_criadas[i + Vector2i(0, 1)]
			var g_vizinho = sala_vizinha.grupo_id if "grupo_id" in sala_vizinha else 0
			tem_s = true
			if g_atual != 0 and g_atual == g_vizinho:
				macro_s = true
			else:
				var nova_porta = porta.instantiate()
				nova_porta.global_position = Vector2((i.x * room_largura) + (room_largura / 2 ), (i.y + 1) * room_altura)
				add_child(nova_porta)
				sala_atual.portas_da_sala.append(nova_porta)
				sala_vizinha.portas_da_sala.append(nova_porta)

		if salas_criadas.has(i + Vector2i(-1, 0)):
			var sala_vizinha = salas_criadas[i + Vector2i(-1, 0)]
			var g_vizinho = sala_vizinha.grupo_id if "grupo_id" in sala_vizinha else 0
			tem_o = true
			if g_atual != 0 and g_atual == g_vizinho:
				macro_o = true

		if salas_criadas.has(i + Vector2i(0, -1)):
			var sala_vizinha = salas_criadas[i + Vector2i(0, -1)]
			var g_vizinho = sala_vizinha.grupo_id if "grupo_id" in sala_vizinha else 0
			tem_n = true
			if g_atual != 0 and g_atual == g_vizinho:
				macro_n = true
			
		sala_atual.ajustar_parede(tem_n, tem_s, tem_l, tem_o)
		if sala_atual.has_method("abrir_divisoria_macro"):
			sala_atual.abrir_divisoria_macro(macro_n, macro_s, macro_l, macro_o)




func sortear_formato_macro(pos_atual: Vector2i) -> Array[Vector2i]:
	if pos_atual == Vector2i.ZERO:
		return [pos_atual]
	
	var chance_macro = clamp(0.20 + (RunData.dificuldade * 0.05), 0.20, 0.70)
	
	if randf() > chance_macro:
		return [pos_atual]

	
	var tamanho_alvo = 3
	var chance_sala_tripla = clamp(0.10 + (RunData.dificuldade * 0.05), 0.10, 0.50)
	if randf() < chance_sala_tripla:
		tamanho_alvo = 3

	var celulas: Array[Vector2i] = [pos_atual]
	var direcoes = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]

	while celulas.size() < tamanho_alvo:
		var celula_base = celulas.pick_random()
		direcoes.shuffle()
		var conseguiu_expandir = false
		
		for dir in direcoes:
			var vizinho = celula_base + dir
			
			# Condições para ser válido:
			# 1. Não sair do mapa para a esquerda (x >= 0)
			# 2. Não colidir com salas que já foram criadas
			# 3. Não ser uma célula que já adicionamos no próprio grupo
			if vizinho.x >= 0 and not salas_criadas.has(vizinho) and not celulas.has(vizinho):
				celulas.append(vizinho)
				conseguiu_expandir = true
				break
		
		# Se estiver cercado e não achar nenhuma casa livre, encerra com o tamanho que deu
		if not conseguiu_expandir:
			break
			
	return celulas
