extends UpgradeData
class_name UpgradeTerremotoSlowStun

func ao_causar_dano(area_atingida, dano, projetil):
	
	if RunData.armas[0].nome != "Terremoto":
		return
	print("Entrou no stun")
	var inimigo = area_atingida.get_parent()
	if not is_instance_valid(inimigo): return
	

	if not inimigo.has_meta("data_clonada"):
		inimigo.data = inimigo.data.duplicate()
		inimigo.set_meta("data_clonada", true)
		inimigo.set_meta("vel_base", inimigo.data.speed)
		
	if self.efeito == "stun":
		if not inimigo.has_meta("stunado"):
			inimigo.set_meta("stunado", true)
			_atualizar_velocidade(inimigo)
			
			var t = inimigo.get_tree().create_timer(1.0)
			t.timeout.connect(func():
				if is_instance_valid(inimigo):
					inimigo.remove_meta("stunado")
					_atualizar_velocidade(inimigo)
			)
			
	elif self.efeito == "slow":
		if not inimigo.has_meta("com_slow"):
			inimigo.set_meta("com_slow", true)
			_atualizar_velocidade(inimigo)
			
			var t = inimigo.get_tree().create_timer(2.0)
			t.timeout.connect(func():
				if is_instance_valid(inimigo):
					inimigo.remove_meta("com_slow")
					_atualizar_velocidade(inimigo)
			)

func _atualizar_velocidade(inimigo):
	if not is_instance_valid(inimigo): return
	var vel_base = inimigo.get_meta("vel_base")
	
	if inimigo.has_meta("stunado"):
		inimigo.data.speed = 0.0
	elif inimigo.has_meta("com_slow"):
		inimigo.data.speed = vel_base * 0.5
	else:
		inimigo.data.speed = vel_base
