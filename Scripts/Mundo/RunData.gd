extends Node

const ANDARES_MAXIMOS = 3

var andar := 1
var moeda_run := 0
var arma_escolhida: ArmaRecurso
var proj_mods: ProjMods


var vida_max := 0.0
var vida_atual := 0.0
var xp_atual := 0.0
var barra_exp := 0.0
var nivel := 1
var dano_adicional := 0
var dificuldade = 1
var mult_dificuldade = 1 + (dificuldade * 0.05)

var gamemode = "Mouse"

func multiplicar_dificuldade() -> float:
	return 1.0 + dificuldade * 0.05

func iniciar_run(personagem: player_data, p_arma: ArmaRecurso) -> void:
	resetar_run()
	andar = 1
	arma_escolhida = p_arma
	proj_mods = preload("res://Recursos/Armas/Arma_mods.tres").duplicate()
	vida_max = personagem.vida
	vida_atual = personagem.vida
	barra_exp = personagem.exp_bar

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
	vida_atual = player.vida_atual
	vida_max = player.vida_maxima
	xp_atual = player.xp_atual
	barra_exp = player.barra_exp
	nivel = player.nivel
	dano_adicional = player.dano_adicional
	proj_mods = player.proj_mods

func carregar_player(player) -> void:
	player.vida_atual = vida_atual
	player.vida_maxima = vida_max
	player.xp_atual = xp_atual
	player.barra_exp = barra_exp
	player.nivel = nivel
	player.dano_adicional = dano_adicional
	player.arma = arma_escolhida
	player.proj_mods = proj_mods

func avancar_andar():
	andar += 1
