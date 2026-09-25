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

func calcular_critico() -> bool:
	return randi_range(1, 100) <= RunData.chance_critico


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
			dano_add += i.valor
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
		print(i.efeito)
		
	RunData.aplicar_modificadores_globais(self)
	
func usar_arma(player,delta, dano_adicional, dano_multiplicador, direcao):
	if buracos_ativo.size() < buracos_totais:
		var dano_atual = dano
		var speed_temp = (speed_calculada + speed) / 2
		dano_atual += dano_add #upgrade
		dano_atual += dano_adicional #artefato
		dano_atual *= dano_multiplicador #artefato
		dano_atual += (RunData.vida_max * 0.01)
		var is_critico = calcular_critico()
		if is_critico:
			dano_atual *= RunData.dano_critico
		var novo_gravity = projetil.instantiate()
		novo_gravity.scale *= tamanho  * RunData.mult_tamanho
		player.get_parent().add_child(novo_gravity)
		novo_gravity.global_position = player.global_position
		novo_gravity.start(dano_atual, player.global_position, speed_temp, direcao, is_critico)
		player.get_node("AttackTimer").start()
		buracos_ativo.append(novo_gravity)
		novo_gravity.tree_exited.connect(func():
			buracos_ativo.erase(novo_gravity)
			)
		
		

func parar_uso(player):
	pass
