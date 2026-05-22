extends item_data

func aplicar_upgrade(player):
	player.vida_maxima += valor_efeito
	player.vida_atual += valor_efeito
	print(player.vida_maxima)
