extends item_data


func aplicar_upgrade(player):
	player.dano_adicional += valor_efeito
	print("Dano adicional: ", player.dano_adicional)
