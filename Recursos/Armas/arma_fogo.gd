extends ArmaRecurso
class_name ArmaFogo

@export var debuff_fogo : DebuffsData
var dano_atual = dano

func usar_arma(player,delta,dano_mult, dano_add):
	dano_atual += dano_add
	dano_atual *= dano_mult
	var o_circulo = player.get_node_or_null("Circulo")
	if o_circulo:
		o_circulo.global_position = o_circulo.global_position.move_toward(player.get_global_mouse_position(), 3)
	else:
		var novo_circulo = projetil.instantiate()
		novo_circulo.name = "Circulo"
		novo_circulo.start(dano_atual)
		novo_circulo.dano_add = dano_add
		player.add_child(novo_circulo)
		player.speed_atual = 100


func parar_uso(player):
	var o_circulo = player.get_node_or_null("Circulo")
	if o_circulo:
		o_circulo.queue_free()
	player.speed_atual = 300
	dano_atual = dano
