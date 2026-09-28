extends ArmaRecurso
class_name ArmaFogo

@export var debuff_fogo : DebuffsData

var tiros_por_burst = 1
var bursts = 1
var speed_calculada = 200
var tamanho = Vector2(1,1)
var bounces = 0
var penetracao = false
var dano_add = 0
var crescimento = 1
var limite = 6
var tempo_vida = 3
var tem_fogo_espalha = false

func calcular_upgrades():
	tiros_por_burst = 1
	bursts = 1
	speed_calculada = 200
	tamanho = Vector2(1,1)
	bounces = 0
	penetracao = false
	tem_fogo_espalha = false
	dano_add = 0
	
	crescimento = 1
	limite = 6
	tempo_vida = 3
	
	for i in upgrades_ativos:
		if i.efeito == "Dano":
			dano_add += i.valor
		if i.efeito == "MultiDisparos":
			bursts += i.valor
		if i.efeito == "velocidade":
			speed_calculada += i.valor
		if i.efeito == "+1Disparo":
			tiros_por_burst += i.valor
		if i.efeito == "tamanho":
			tamanho *= i.valor
		if i.efeito == "bounce":
			bounces += i.valor
		if i.efeito == "fogo_crescimento":
			crescimento += i.valor
		if i.efeito == "fogo_limite":
			limite += i.valor
		if i.efeito == "fogo_tempoVida":
			tempo_vida += i.valor
		if i.efeito == "fogo_espalha":
			tem_fogo_espalha = true
		if i.efeito == "penetracao":
			penetracao = true
			
	RunData.aplicar_modificadores_globais(self)
	
	
func usar_arma(player,delta, dano_adicional,  dano_multiplicador, direcao):
	var daninho = dano
	daninho += dano_add #upgrade
	daninho += dano_adicional #artefato
	daninho *= dano_multiplicador #artefato
	var i = 0
	if player.get_node("VolleyCooldown").is_stopped():
		while i <= bursts - 1: 
			var novo_circulo = projetil.instantiate()
			novo_circulo.scale *= tamanho * RunData.mult_tamanho
			novo_circulo.start(daninho, crescimento, limite, tempo_vida)
			novo_circulo.dano_add = dano_add
			player.get_parent().add_child(novo_circulo)
			i += 1
		player.get_node("VolleyCooldown").start(2) #cooldown por lote
	RunData.speed_calculado = 100
	


func parar_uso(player):
	RunData.speed_calculado = 300
