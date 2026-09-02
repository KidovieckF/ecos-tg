extends ArmaRecurso
class_name ArmaTerremoto

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
	dano_add = 0
	
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

func usar_arma(player,delta, dano_adicional,  dano_multiplicador, direcao):
	var daninho = dano
	daninho += dano_add #upgrade
	daninho += dano_adicional #artefato
	dano_add *= dano_multiplicador #artefato
	var novo_circulo = projetil.instantiate()
	novo_circulo.scale *= tamanho
	novo_circulo.start(daninho)
	player.get_parent().add_child(novo_circulo)
	
func parar_uso(player):
	pass
