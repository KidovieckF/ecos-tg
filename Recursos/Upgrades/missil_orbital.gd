extends UpgradeData
class_name UpgradeOrbital

var controlador = null

func ao_atualizar_jogador(player, delta):
	# Se o controlador visual da órbita ainda não existe no player, a gente cria e gruda ele!
	if controlador == null or not is_instance_valid(controlador):
		controlador = Node2D.new()
		controlador.set_script(preload("res://Scripts/Upgrades/missil_orbital.gd"))
		player.add_child(controlador)
