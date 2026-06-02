extends ArmaRecurso
class_name MissilMagico

var carga = true

func usar_arma(player,delta,dano_mult,dano_add):
	var dano_atual = dano
	var i = 0
	player.get_node("AttackTimer").start()
	while i <= player.proj_mods.proj_extras:
		dano_atual += dano_add
		dano_atual *= dano_mult
		var novo_missil = projetil.instantiate()
		novo_missil.scale *= player.proj_mods.tamanho
		novo_missil.start(dano_atual, speed, player.proj_mods.proj_extras + 1, i, player.proj_mods.bounces)
		novo_missil.global_position = player.global_position
		player.get_parent().add_child(novo_missil)
		i += 1

func parar_uso(player):
	pass
