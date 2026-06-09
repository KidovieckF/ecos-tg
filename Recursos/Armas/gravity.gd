extends ArmaRecurso
class_name GravityArma

var buracos_ativo = []
var buracos_totais = 1

func usar_arma(player,delta,dano_mult, dano_add):
	if buracos_ativo.size() < buracos_totais:
		var dano_atual = dano
		dano_atual += dano_add
		dano_atual *= dano_mult
		dano_atual += (player.vida_maxima * 0.01)
		var novo_gravity = projetil.instantiate()
		novo_gravity.scale *= player.proj_mods.tamanho
		player.get_parent().add_child(novo_gravity)
		novo_gravity.global_position = player.global_position
		novo_gravity.start(dano_atual, player.global_position, speed)
		player.get_node("AttackTimer").start()
		buracos_ativo.append(novo_gravity)
		novo_gravity.tree_exited.connect(func():
			buracos_ativo.erase(novo_gravity)
			)
		
		

func parar_uso(player):
	pass
