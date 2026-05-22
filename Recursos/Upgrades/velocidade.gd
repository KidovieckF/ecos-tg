extends item_data


func aplicar_upgrade(player):
	player.speed_atual += valor_efeito
	print(player.speed_atual)
