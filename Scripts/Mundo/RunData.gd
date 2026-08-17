extends Node

const ANDARES_MAXIMOS = 3

signal inventario_atualizado

var tela_pause_atual = null

var armas: Array[ArmaRecurso] = [null, null]

var andar := 1
var moeda_run := 0
var arma_escolhida: ArmaRecurso
var proj_mods: ProjMods


var artefatos_coletados : Array[Artefato_data] = []
var personagem_base: player_data

var speed_calculado: float = 300.0
var vida_max := 0.0
var vida_atual := 0.0
var xp_atual := 0.0
var barra_exp := 0.0
var nivel := 1
var dano_adicional := 0
var dificuldade = 1
var mult_dificuldade = 1 + (dificuldade * 0.05)
var dano_mult_final = 1.0
var gamemode = "Mouse"

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event):
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
	var dano = 0.0
	var vida = personagem_base.vida
	var speed = personagem_base.speed
	var mult = 1
	
	for i in artefatos_coletados:
		dano += i.dano_add
		vida += i.vida_max_add
		speed += i.speed_add 
		mult += i.dano_mult
		
	for j in artefatos_coletados:
		vida *= j.vida_max_mult
		speed *= j.speed_mult
		
	dano *= mult
	dano_adicional = dano
	vida_max = vida
	speed_calculado = speed
	dano_mult_final = mult
	

func adicionar_artefato(artefato : Artefato_data):
	artefatos_coletados.append(artefato)
	inventario_atualizado.emit()
	if artefato.vida_max_add > 0:
		vida_atual += artefato.vida_max_add
	if artefato.vida_max_mult > 1:
		vida_atual *= artefato.vida_max_mult
	artefato.efeito()
	calcular_artefatos()

func multiplicar_dificuldade() -> float:
	return 1.0 + dificuldade * 0.05

func iniciar_run(personagem: player_data, p_arma: ArmaRecurso) -> void:
	resetar_run()
	andar = 1
	arma_escolhida = p_arma
	armas[0] = arma_escolhida
	proj_mods = preload("res://Recursos/Armas/Arma_mods.tres").duplicate()
	vida_max = personagem.vida
	vida_atual = personagem.vida
	barra_exp = personagem.exp_bar
	speed_calculado = personagem.speed
	personagem_base = personagem
	artefatos_coletados.clear()
	

func resetar_run() -> void:
	andar = 1
	moeda_run = 0
	arma_escolhida = null
	proj_mods = null
	vida_max = 0
	vida_atual = 0
	xp_atual = 0
	barra_exp = 0
	nivel = 1
	dano_adicional = 0
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
	player.proj_mods = proj_mods

func avancar_andar():
	andar += 1
