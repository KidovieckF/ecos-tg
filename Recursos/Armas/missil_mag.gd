extends ArmaRecurso
class_name MissilMagico


var cooldown = 0
var tiros_por_burst = 1
var bursts = 1
var speed_calculada = 200
var tamanho = Vector2(1,1)
var bounces = 0
var penetracao = false

func calcular_upgrades():
	tiros_por_burst = 1
	bursts = 1
	speed_calculada = 200
	tamanho = Vector2(1,1)
	bounces = 0
	penetracao = false
	print("Teste")
	for i in upgrades_ativos:
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
			
			
	

func disparar_burst(player, dano_mult, dano_add, proj_por_burst,direcao):
	for i in range(proj_por_burst):
		var dano_atual = dano
		dano_atual += dano_add
		dano_atual *= dano_mult
		var novo_missil = projetil.instantiate()
		player.get_parent().add_child(novo_missil)
		novo_missil.global_position = player.global_position
		novo_missil.start(dano_atual, speed_calculada, proj_por_burst, i, bounces, penetracao, direcao)
										#Dano, Velocidade, Burst, i, bounces, perfurante
		
func usar_arma(player, delta, dano_mult, direcao):
	print("atirei")
	var intervalo = 0.08
	for idx in range(bursts):
		if idx == 0:
			disparar_burst(player, dano_mult, tiros_por_burst, direcao)
		else:
			var timer = player.get_tree().create_timer(idx * intervalo)
			timer.timeout.connect(func():
				disparar_burst(player, dano_mult, tiros_por_burst, direcao)
			)
	player.get_node("AttackTimer").start()
	
func parar_uso(player):
	pass
