extends MascoteRucurso
class_name MascoteGreg

var tempo_descanso = 0.0
var esta_pulando = false

func movimentacao(mascote_body, player):
	var delta = mascote_body.get_physics_process_delta_time()
	
	var distancia = mascote_body.global_position.distance_to(player.global_position)
	var direcao = (player.global_position - mascote_body.global_position).normalized()
	
	if esta_pulando:
		mascote_body.velocity = mascote_body.velocity.move_toward(Vector2.ZERO, 1500 * delta)
		if mascote_body.velocity.length() < 10:
			esta_pulando = false
			tempo_descanso = 1.0
	else:
		tempo_descanso -= delta
		if tempo_descanso <= 0 and distancia > 80:

			var distancia_alvo = max(0, distancia - 60)
			var forca_pulo = sqrt(3000.0 * distancia_alvo)
			forca_pulo = max(400.0, forca_pulo)
			mascote_body.velocity = direcao * forca_pulo
			esta_pulando = true
			
			var sprite_node = mascote_body.get_node("Sprite2D")
			var tempo_voo = forca_pulo / 1500.0 
			
			var altura_pulo = -80.0 * (forca_pulo / 800.0)
			
			var tween_arco = mascote_body.create_tween().set_trans(Tween.TRANS_QUAD)
			tween_arco.tween_property(sprite_node, "position:y", altura_pulo, tempo_voo / 2.0).set_ease(Tween.EASE_OUT)
			tween_arco.tween_property(sprite_node, "position:y", 0.0, tempo_voo / 2.0).set_ease(Tween.EASE_IN)

func atacar(mascote_body, inimigo):
	var nova_bomba = projetil.instantiate()
	mascote_body.get_parent().add_child(nova_bomba)
	
	nova_bomba.global_position = mascote_body.global_position
	
	var alvo_posicao = inimigo.global_position
	if nova_bomba.has_method("lancar"):
		nova_bomba.lancar(alvo_posicao, dano)
