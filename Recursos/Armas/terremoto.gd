extends ArmaRecurso
class_name ArmaTerremoto

var tiros_por_burst = 1
var bursts = 1
var speed_calculada = 200
var tamanho = Vector2(1,1)
var bounces = 0
var penetracao = false
var dano_add = 0
var velocidade_de_tick = 0
var tem_alice_gorda = false


func calcular_critico() -> bool:
	return randi_range(1, 100) <= RunData.chance_critico

func calcular_upgrades():
	tiros_por_burst = 1
	bursts = 1
	speed_calculada = 200
	tamanho = Vector2(1,1)
	bounces = 0
	penetracao = false
	dano_add = 0
	tem_alice_gorda = false
	velocidade_de_tick = 0
	

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
		if i.efeito == "terremoto_danotick":
			velocidade_de_tick += i.valor
		if i.efeito == "terremoto_passos":
			tem_alice_gorda = true
		if i.efeito == "penetracao":
			penetracao = true
	
	RunData.aplicar_modificadores_globais(self)

func usar_arma(player,delta, dano_adicional,  dano_multiplicador, direcao):
	if tem_alice_gorda:
		return
	var daninho = dano
	daninho += dano_add #upgrade
	daninho += dano_adicional #artefato
	daninho += velocidade_de_tick #Upgrade de arma
	daninho *= dano_multiplicador #artefato
	
	var i = 0
	var is_critico = calcular_critico()
	if is_critico:
		daninho *= RunData.dano_critico
	if player.get_node("VolleyCooldown").is_stopped():
		while i <= bursts - 1: 
			var novo_circulo = projetil.instantiate()
			novo_circulo.scale *= tamanho  * RunData.mult_tamanho
			novo_circulo.start(daninho, is_critico, velocidade_de_tick)
			player.get_parent().add_child(novo_circulo)
			player.get_node("VolleyCooldown").start(2)
			i += 1
			for upgrade in upgrades_ativos:

				if upgrade.efeito == "stun" or upgrade.efeito == "slow":
					novo_circulo.area_entered.connect(func(area):
						if area.has_method("take_damage"):
							upgrade.ao_causar_dano(area, daninho, novo_circulo)
					)
func parar_uso(player):
	pass
