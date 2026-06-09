extends item_data
class_name VelocidadeAtaqueData


func aplicar_upgrade(player):
	player.get_node("AttackTimer").wait_time -= valor_efeito
