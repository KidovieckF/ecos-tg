extends Node2D

var portas_da_sala = []
var contador_inimigos = 0
var sensor_ja_ativado = false
var tempo_de_vida = 0
var lista_inimigos = []
var round_atual = 1
var round_maximo =  4
var tamanho_onda = 4
var inimigo = preload("res://Cenas/Inimigos/inimigo_base.tscn")
var player

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	tempo_de_vida += delta
	if sensor_ja_ativado == false and tempo_de_vida > 0.5:
		for i in $Area2D.get_overlapping_bodies():
			if i.is_in_group("Players"):
				player = i
				chamar_onda()
				sensor_ja_ativado = true

func verifica_inimigos():
	round_maximo = randf_range(2,5)
	lista_inimigos = lista_inimigos.filter(func(i): return is_instance_valid(i) and not i.is_queued_for_deletion())
	contador_inimigos = lista_inimigos.size()
	if contador_inimigos == 0:
		if round_atual < round_maximo:
			await get_tree().create_timer(3.0).timeout
			chamar_onda()
			round_atual += 1
		else:
			for p in portas_da_sala:
				p.abrir_porta()
				print("sala limpa")

func ajustar_parede(norte, sul, leste, oeste):
	if norte == true:
		$ParedeNorte.clear()
	if sul == true:
		$ParedeSul.clear()
	if leste == true:
		$ParedeLeste.clear()
	if oeste == true:
		$ParedeOeste.clear()

func _on_area_2d_body_entered(body: Node2D) -> void:
	inicar_sala(body)
	print("SALA: ", name, " | DETECTOU: ", body.name, " | POSIÇÃO DO CORPO: ", body.global_position)
	
	
func inicar_sala(body):
	if sensor_ja_ativado == false and tempo_de_vida > 0.5:
		if body.is_in_group("Players"):
			print("Detector de sala ativado por: ", body.name)
			player = body
			chamar_onda()
			for p in portas_da_sala:
				print("fechei a porta")
				p.fechar_porta()
		
		sensor_ja_ativado = true

func chamar_onda():
	tamanho_onda =  randi_range(3, 15)
	
	
	if tamanho_onda < 7:
		for i in range(tamanho_onda):
			registrar_inimigo()
			await get_tree().create_timer(1.0).timeout
	else:
		for i in range(tamanho_onda/2):
			registrar_inimigo()
			registrar_inimigo()
			await get_tree().create_timer(1.0).timeout
			
func registrar_inimigo():
	var novo_inimigo = inimigo.instantiate()
	var rand_x = randf_range(50, 1000)
	var rand_y = randf_range(40, 590)
	novo_inimigo.position = Vector2(rand_x, rand_y)
	novo_inimigo.player = player
	lista_inimigos.append(novo_inimigo)
	add_child(novo_inimigo)
	novo_inimigo.morreu.connect(verifica_inimigos)
	
