extends item_data
class_name TamanhoData

var valor_efeito_atual

func aplicar_upgrade(player):
	valor_efeito_atual += valor_efeito
	player.proj_mods.tamanho *= valor_efeito_atual
