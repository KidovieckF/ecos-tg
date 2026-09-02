extends MascoteRucurso
class_name MascoteStellae


func movimentacao(mascote_body, player):
	var direction = (player.global_position - mascote_body.global_position).normalized()
	var distancia = mascote_body.global_position.distance_to(player.global_position)
	if distancia > 50:
		mascote_body.velocity = direction * 300
	else:
		mascote_body.velocity = Vector2.ZERO

func atacar(mascote_body, inimigo):
	print("teste")
	var nova_magia = projetil.instantiate()
	mascote_body.get_parent().add_child(nova_magia)
	var direcao_calculada = (inimigo.global_position - mascote_body.global_position).normalized()
	nova_magia.start(mascote_body.global_position, direcao_calculada, dano)
