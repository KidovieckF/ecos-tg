extends item_data
class_name TamanhoData

var valor_efeito_atual

func aplicar_upgrade(player):
	player.proj_mods.tamanho *= valor_efeito
