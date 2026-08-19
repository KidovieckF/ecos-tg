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

func calcular_upgrades():
	tiros_por_burst = 1
	bursts = 1
	speed_calculada = 200
	tamanho = Vector2(1,1)
	bounces = 0
	penetracao = false
	print("Teste")
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
		if i.efeito == "penetracao":
			penetracao = true

func usar_arma(player,delta, dano_mult, direcao):
	var daninho = (dano + dano_add) * dano_mult
	var i = 0
	if player.get_node("VolleyCooldown").is_stopped():
		while i <= 2: #proj extras
			var novo_circulo = projetil.instantiate()
			novo_circulo.start(daninho)
			novo_circulo.dano_add = dano_add
			player.get_parent().add_child(novo_circulo)
			i += 1
		player.get_node("VolleyCooldown").start(2) #cooldown por lote
	RunData.speed_calculado = 100
	


func parar_uso(player):
	RunData.speed_calculado = 300
