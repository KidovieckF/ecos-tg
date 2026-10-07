extends "res://Scripts/Inimigos/boss_base.gd"

var cena_pedra = preload("res://Cenas/Inimigos/Bosses/Bola_golem.tscn")
var cena_linha = preload("res://Cenas/Inimigos/Bosses/Linha_aviso.tscn")
var projetil = preload("res://Cenas/Inimigos/Bosses/Bola.tscn")
@onready var player = get_tree().get_first_node_in_group("Players")


func _ready() -> void:
	print("vida atual:", vida_atual )
	cutscene_inicial()
	$Corpo_golem/Mao_esquerda.visible = true
	
	

func cutscene_inicial():
	player.set_physics_process(false)
	await get_tree().create_timer(2.0).timeout
	player.get_node("CameraJogo").tremor(300)
	revelar_barra()
	await get_tree().create_timer(2.0).timeout
	player.set_physics_process(true)
	timer_ataque.start()

func jogar_pedra_no_player():
	anim.play("Ataque bola")
	
	var pedra = cena_pedra.instantiate()
	get_parent().add_child(pedra)
	pedra.global_position = player.global_position
	
	await get_tree().create_timer(1.5).timeout
	finalizar_ataque()

func gerar_xadrez():
	anim.play("Ataque bola")
	
	var espacamento = 150 
	var colunas = 8
	var linhas = 5 
	

	var inicio_x = global_position.x - 1100
	var inicio_y = global_position.y - 300

	for x in range(colunas):
		for y in range(linhas):
			if (x + y) % 2 == 0:
				var pedra = cena_pedra.instantiate()
				get_parent().add_child(pedra)
				var pos_calculada = Vector2(inicio_x + (x * espacamento), inicio_y + (y * espacamento))
				pedra.global_position = pos_calculada
				
	await get_tree().create_timer(2.5).timeout
	finalizar_ataque()


func ataque_retas_cruzadas():
	anim.play("Ataque bola")
	
	var espacamento = 120
	var quantidade_linhas = 8
	
	var deslocamento = randi_range(-30, 30) 
	
	var inicio_y = (global_position.y - 320) + deslocamento
	
	for i in range(quantidade_linhas):
		var linha = cena_linha.instantiate()
		get_parent().add_child(linha)
		
		var altura_calculada = inicio_y + (i * espacamento)
		linha.global_position = Vector2(global_position.x, altura_calculada)
		
	await get_tree().create_timer(3.0).timeout
	finalizar_ataque()
	
	

func ataque_metralhadora():
	anim.play("Lançar bola")
	var offset_mao = Vector2(-235, 2)
	
	for i in range(20):
		var espalhamento = randf_range(-5, 5) 
		
		var novo_tiro = projetil.instantiate()
		get_parent().add_child(novo_tiro)
		
		var ponto_de_saida = global_position + offset_mao
		
		var direcao = (player.global_position - ponto_de_saida).normalized().rotated(deg_to_rad(espalhamento))
		novo_tiro.global_position = ponto_de_saida
		novo_tiro.start(ponto_de_saida, direcao) 
		await get_tree().create_timer(randf_range(0.05, 0.15)).timeout
	await get_tree().create_timer(1.0).timeout
	finalizar_ataque()
