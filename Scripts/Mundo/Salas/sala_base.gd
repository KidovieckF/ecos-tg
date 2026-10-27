extends Node2D

var portas_da_sala = []
var contador_inimigos = 0
var sensor_ja_ativado = false
var tempo_de_vida = 0
var lista_inimigos = []
var round_atual = 1
var round_maximo = 4
var tamanho_onda = 4
var inimigo = preload("res://Cenas/Inimigos/inimigo_base.tscn")
var elite = preload("res://Cenas/Inimigos/inimigo_atirador.tscn")
var player
var deu_grandao = false
var deu_suculento = false
var deu_ultimato = false
var processando_onda = false
var sala_limpa = false
var dificuldade = 1


#Grupo de salas 
var grupo_id: int = 0
var eh_mestre: bool = true
var sala_mestre: Node2D = null
var celulas_do_grupo: Array[Node2D] = []

@export var tipos_inimigos : Array[inimigo_data]


func _ready() -> void:
	tamanho_onda = randi_range(3, 8)
	round_maximo = randi_range(2, 4)
	espalhar_flores_aleatorias()

func _physics_process(delta: float) -> void:
	tempo_de_vida += delta

func espalhar_flores_aleatorias() -> void:
	var catalogo_flores = [
		{ "source": 4, "coords": Vector2i(0, 0) }, 
		{ "source": 5, "coords": Vector2i(0, 0) }, 
		{ "source": 6, "coords": Vector2i(0, 0) }, 
		{ "source": 7, "coords": Vector2i(0, 0) }, 
	]
	
	var chance_flor = 0.08
	
	for celula in $Chao.get_used_cells():
		if randf() < chance_flor:
			var flor = catalogo_flores.pick_random()
			$Chao.set_cell(celula, flor.source, flor.coords)


func verifica_inimigos():
	if sala_limpa or processando_onda:
		return
		
	lista_inimigos = lista_inimigos.filter(func(i): return is_instance_valid(i) and not i.is_queued_for_deletion())
	contador_inimigos = lista_inimigos.size()
	
	if contador_inimigos == 0:
		if round_atual < round_maximo:
			round_atual += 1
			await get_tree().create_timer(3.0, false).timeout
			await chamar_onda()
		else:
			sala_limpa = true
			for p in portas_da_sala:
				p.abrir_porta()
				print("sala limpa")

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	inicar_sala(body)
	print("SALA: ", name, " | DETECTOU: ", body.name, " | POSIÇÃO DO CORPO: ", body.global_position)

func inicar_sala(body):
	#verifica se é mestre para iniciar
	if not eh_mestre and sala_mestre:
		sala_mestre.inicar_sala(body)
		return
	# Verica o tamanho da sala para ser proporcional ao tamamho da onda
	if celulas_do_grupo.size() > 1:
		tamanho_onda = int(tamanho_onda * (1.0 + (celulas_do_grupo.size() - 1) * 0.7))

		
	if sensor_ja_ativado == false and tempo_de_vida > 0.5:
		if body.is_in_group("Players"):
			sensor_ja_ativado = true
			RunData.dificuldade += dificuldade
			print("Dificuldade: ", RunData.dificuldade)
			
			for p in portas_da_sala:
				print("fechei a porta")
				p.fechar_porta()
			print("Detector de sala ativado por: ", body.name)
			player = body
			$CanvasLayer.iniciar_roleta()
			await get_tree().create_timer(5.0, false).timeout
			await chamar_onda()

func chamar_onda():
	processando_onda = true
	
	if tamanho_onda < 7:
		for i in range(tamanho_onda):
			registrar_inimigo()
			await get_tree().create_timer(1.0, false).timeout
	else:
		for i in range(tamanho_onda/2):
			registrar_inimigo()
			registrar_inimigo()
			await get_tree().create_timer(1.0, false).timeout
			
	if deu_ultimato and round_atual == round_maximo:
		var novo_elite = elite.instantiate()
		novo_elite.position = Vector2(500, 295)
		novo_elite.player = player
		add_child(novo_elite)
		lista_inimigos.append(novo_elite)
		novo_elite.morreu.connect(verifica_inimigos)
		
	processando_onda = false
	verifica_inimigos()
			
func registrar_inimigo():
	var tipos_validos = tipos_inimigos.filter(func(tipo): 
		return tipo.dificuldade_minima <= RunData.dificuldade
	)
	if tipos_validos.is_empty():
		tipos_validos = tipos_inimigos

	var peso_total = 0
	for tipo in tipos_validos:
		peso_total += tipo.peso_spawn

	var roll = randi_range(1, peso_total)
	var data_sorteado = tipos_validos[0]
	for tipo in tipos_validos:
		roll -= tipo.peso_spawn
		if roll <= 0:
			data_sorteado = tipo
			break

	var cena_a_instanciar = data_sorteado.cena_inimigo if data_sorteado.cena_inimigo else inimigo
	var novo_inimigo = cena_a_instanciar.instantiate()
	
	var celula_escolhida = celulas_do_grupo.pick_random() if celulas_do_grupo.size() > 0 else self
	var rand_x = randf_range(50, 1000)
	var rand_y = randf_range(40, 590)
	novo_inimigo.position = Vector2(rand_x, rand_y)
	novo_inimigo.player = player
	novo_inimigo.data = data_sorteado
	celula_escolhida.add_child(novo_inimigo)

	if deu_grandao:
		novo_inimigo.scale = Vector2(2, 2)
	lista_inimigos.append(novo_inimigo)
	
	novo_inimigo.morreu.connect(verifica_inimigos)
	novo_inimigo.morreu.connect(func():
		player.ganhar_xp(novo_inimigo.data.exp)
	)




func _on_canvas_layer_resultado_roleta(recompensa: String) -> void:
	match recompensa: 
		"multirao":
			tamanho_onda += 2
			print("mult")
		"ultimato":
			print("ultimato")
			deu_ultimato = true
		"grandao":
			print("grandao")
			deu_grandao = true
		"suculento":
			print("suculento")
			deu_suculento = true
		"morte":
			print("morte")
			tamanho_onda += 2
			deu_ultimato = true
			deu_grandao = true
			deu_suculento = true
