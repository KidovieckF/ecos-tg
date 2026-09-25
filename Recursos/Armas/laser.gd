extends ArmaRecurso
class_name LaserRecurso

var tween_fade
var dano_carregado = 0.0
var charge_ativo = null

var tiros_por_burst = 1
var bursts = 1
var speed_calculada = 200
var tamanho = Vector2(1,1)
var bounces = 0
var dano_add = 0
var penetracao = false
var foi_critico : bool

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
			
	RunData.aplicar_modificadores_globais(self)



func usar_arma(player,delta, dano_adicional, dano_multiplicador, direcao):

	if player.get_node("AttackTimer").is_stopped():
		if dano_carregado < 10:
			dano_carregado += delta * 2 # Carrega o dano aos poucos
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
		var dano_final = dano + dano_carregado
		dano_final += dano_add
		dano_final += RunData.dano_adicional
		dano_final *= RunData.dano_multiplicador
		var is_critico = calcular_critico()
		if is_critico:
			dano_final *= RunData.dano_critico
		var novo_laser = projetil.instantiate()
		if RunData.mult_tamanho > 1:
			novo_laser.scale *= tamanho  * RunData.mult_tamanho
		else:
			novo_laser.scale.y *= tamanho.y * RunData.mult_tamanho
		player.get_parent().add_child(novo_laser)
		novo_laser.global_position = player.get_node("Muzzle").global_position
		novo_laser.start(dano_final, player.global_position, is_critico)
		tween_fade = player.create_tween()
		tween_fade.tween_property(novo_laser, "modulate:a", 0.0, 1)
		tween_fade.tween_callback(novo_laser.queue_free)
		RunData.speed_calculado = 300
		dano_carregado = 0.0
		if charge_ativo != null:
			charge_ativo.queue_free()
		charge_ativo = null
		player.get_node("AttackTimer").wait_time = 3.0 / RunData.mult_de_atk_speed
		player.get_node("AttackTimer").start()
