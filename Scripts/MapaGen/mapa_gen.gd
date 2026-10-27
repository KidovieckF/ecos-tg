extends Node

@export var player: CharacterBody2D
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
		salas_possiveis =salas_andar2.duplicate()
		
	generate_level()# Replace with function body.
	player.trocar_camera()
	configurar_entrada_e_animacao()
	
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
	var current_pos = Vector2i(0, 0)
	var directions = [Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	
	while salas_criadas.size() < 15:
		var walk_dir = directions.pick_random()
		var sala_sorteada = salas_possiveis.pick_random()
		directions = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]
		
		if (current_pos + walk_dir).x < 0:
			continue
			
		var nova_sala = null
		
		# 1. Salas Especiais (Sempre 1x1)
		if salas_criadas.size() == 15:
			nova_sala = sala_boss.instantiate()
		elif salas_criadas.size() == 8:
			nova_sala = sala_miniboss.instantiate()
		elif salas_criadas.size() < 1:
			nova_sala = sala_sorteada.instantiate()
		elif not loja_criada and (randi_range(0, 10) <= 1 or pity >= 3):
			nova_sala = loja.instantiate()
			loja_criada = true
		else:
			if not loja_criada:
				pity += 1
				
			var celulas_alvo = sortear_formato_macro(current_pos)
			print(">>> MACRO-SALA GERADA COM ", celulas_alvo.size(), " TELAS! Coordenadas: ", celulas_alvo)
			
			var g_id = proximo_grupo_id
			proximo_grupo_id += 1
			var primeira_sala: Node2D = null
			
			for c_pos in celulas_alvo:
				if not salas_criadas.has(c_pos):
					var s = sala_sorteada.instantiate()
					s.global_position = Vector2(c_pos.x * room_size.x, c_pos.y * room_size.y)
					s.grupo_id = g_id
					get_parent().add_child.call_deferred(s)
					salas_criadas[c_pos] = s
					
					if primeira_sala == null:
						primeira_sala = s
						s.eh_mestre = true
					else:
						s.eh_mestre = false
						s.sala_mestre = primeira_sala
						
					primeira_sala.celulas_do_grupo.append(s)
					
			current_pos = celulas_alvo.back()
			
		if nova_sala != null and not salas_criadas.has(current_pos):
			nova_sala.global_position = Vector2(current_pos.x * room_size.x, current_pos.y * room_size.y)
			get_parent().add_child.call_deferred(nova_sala)
			salas_criadas[current_pos] = nova_sala
			
		current_pos += walk_dir
		
	criar_porta()
	player.position = room_size / 2
	print("Player gerado no ", player.position)

	
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
	
	#var chance_macro = clamp(0.20 + (RunData.dificuldade * 0.05), 0.20, 0.70)
	var chance_macro = 1.0
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
