extends ArmaRecurso
class_name LaserRecurso

var tween_fade
var dano_atual = dano
var charge_ativo = null

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



func usar_arma(player,delta, dano_adicional, dano_multiplicador, direcao):
	
	dano_atual += dano_add #upgrade
	dano_atual += dano_adicional #artefato
	dano_atual *= dano_multiplicador #artefato
	
	if player.get_node("AttackTimer").is_stopped():
		if dano_atual < 10:
			dano_atual += delta * 2
		if charge_ativo == null:
			charge_ativo = efeito.instantiate()
			player.add_child(charge_ativo)
			var animacao = charge_ativo.get_node("Charge")
			animacao.play("charge")

	if charge_ativo != null:
			charge_ativo.global_position = player.get_node("Muzzle").global_position - Vector2(0, 20)
			charge_ativo.look_at(player.get_global_mouse_position())
	


func parar_uso(player):
	if player.get_node("AttackTimer").is_stopped():
		print("soltou")
		RunData.speed_calculado = 0
		var novo_laser = projetil.instantiate()
		novo_laser.scale *= tamanho
		player.get_parent().add_child(novo_laser)
		novo_laser.global_position = player.get_node("Muzzle").global_position
		novo_laser.start(dano_atual, player.global_position)
		tween_fade = player.create_tween()
		tween_fade.tween_property(novo_laser, "modulate:a", 0.0, 1)
		tween_fade.tween_callback(novo_laser.queue_free)
		RunData.speed_calculado = 300
		dano_atual = dano
		if charge_ativo != null:
			charge_ativo.queue_free()
		charge_ativo = null
		player.get_node("AttackTimer").wait_time = 3
		player.get_node("AttackTimer").start()
