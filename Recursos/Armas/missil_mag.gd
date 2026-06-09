extends ArmaRecurso
class_name MissilMagico

var cargas_restantes = 0
var cooldown = 0
var dano_atual = dano

func disparar_burst(player, dano_mult, dano_add, proj_por_burst):
	for i in range(proj_por_burst):
		dano_atual += dano_add
		dano_atual *= dano_mult
		var novo_missil = projetil.instantiate()
		novo_missil.scale *= player.proj_mods.tamanho
		player.get_parent().add_child(novo_missil)
		novo_missil.global_position = player.global_position
		novo_missil.start(dano_atual, player.proj_mods.velocidade, proj_por_burst, i, player.proj_mods.bounces, player.proj_mods.perfurante)
		
func usar_arma(player, delta, dano_mult, dano_add):
	print("atirei")
	var total = player.proj_mods.rajada
	var proj_por_burst = player.proj_mods.proj_extras + 1
	var intervalo = 0.08

	for idx in range(total):
		if idx == 0:
			disparar_burst(player, dano_mult, dano_add, proj_por_burst)
		else:
			var timer = player.get_tree().create_timer(idx * intervalo)
			timer.timeout.connect(func():
				disparar_burst(player, dano_mult, dano_add, proj_por_burst)
			)

	player.get_node("AttackTimer").start()
func parar_uso(player):
	pass
