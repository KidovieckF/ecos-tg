extends UpgradeData
class_name UpgradeTeleguiado

func ao_atirar(player, direcao, bala_criada):
	var controlador = Node.new()
	controlador.set_script(preload("res://Scripts/Upgrades/bala_teleguiada.gd"))
	
	bala_criada.add_child(controlador)
