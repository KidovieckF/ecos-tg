extends ArmaRecurso
class_name LaserRecurso

var tween_fade
var dano_atual = dano
var charge_ativo = null

func usar_arma(player,delta):
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
		player.speed_atual = 0
		var novo_laser = projetil.instantiate()
		player.get_parent().add_child(novo_laser)
		novo_laser.global_position = player.get_node("Muzzle").global_position
		novo_laser.start(dano_atual, player.global_position)
		tween_fade = player.create_tween()
		tween_fade.tween_property(novo_laser, "modulate:a", 0.0, 1)
		tween_fade.tween_callback(novo_laser.queue_free)
		player.speed_atual = 300
		dano_atual = dano
		if charge_ativo != null:
			charge_ativo.queue_free()
		charge_ativo = null
		player.get_node("AttackTimer").wait_time = 3
		player.get_node("AttackTimer").start()
