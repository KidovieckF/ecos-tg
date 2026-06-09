extends ArmaRecurso
class_name ArmaFogo

@export var debuff_fogo : DebuffsData
var dano_atual = dano


func usar_arma(player,delta,dano_mult, dano_add):
	dano_atual += dano_add
	dano_atual *= dano_mult
	var i = 0
	if player.get_node("VolleyCooldown").is_stopped():
		while i < player.proj_mods.proj_extras:
			var novo_circulo = projetil.instantiate()
			novo_circulo.scale *= player.proj_mods.tamanho
			novo_circulo.start(dano_atual)
			novo_circulo.dano_add = dano_add
			player.get_parent().add_child(novo_circulo)
			i += 1
		player.get_node("VolleyCooldown").start(player.proj_mods.cooldown_lote)
	player.speed_atual = 100
	


func parar_uso(player):
	player.speed_atual = 300
	dano_atual = dano
