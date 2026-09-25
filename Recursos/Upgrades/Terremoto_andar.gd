extends UpgradeData
class_name UpgradeAndarTerremoto

var controlador = null

func ao_atualizar_jogador(player, delta):
	if controlador == null or not is_instance_valid(controlador):
		controlador = Node2D.new()
		controlador.set_script(preload("res://Scripts/Upgrades/terromoto_andare.gd"))
		player.add_child(controlador)
