extends ArmaRecurso
class_name GravityArma

var buracos_ativo = []
var buracos_totais = 1

var tiros_por_burst = 1
var bursts = 1
var speed_calculada = 200
var tamanho = Vector2(1,1)
var bounces = 0
var dano_add = 0
var penetracao = false

func calcular_upgrades():
	tiros_por_burst = 1
	bursts = 1
	speed_calculada = 200
	tamanho = Vector2(1,1)
	bounces = 0
	dano_add = 0
	penetracao = false
	print("Teste")
	for i in upgrades_ativos:
		if i.efeito == "MultiDisparos":
			bursts += i.valor
		if i.efeito == "Dano":
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

func usar_arma(player,delta,dano_mult, direcao):
	if buracos_ativo.size() < buracos_totais:
		var dano_atual = dano
		dano_atual += dano_add
		dano_atual *= dano_mult
		dano_atual += (RunData.vida_max * 0.01)
		var novo_gravity = projetil.instantiate()
		player.get_parent().add_child(novo_gravity)
		novo_gravity.global_position = player.global_position
		novo_gravity.start(dano_atual, player.global_position, speed, direcao)
		player.get_node("AttackTimer").start()
		buracos_ativo.append(novo_gravity)
		novo_gravity.tree_exited.connect(func():
			buracos_ativo.erase(novo_gravity)
			)
		
		

func parar_uso(player):
	pass
