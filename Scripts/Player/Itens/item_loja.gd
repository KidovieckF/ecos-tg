extends TextureButton

@export var item :item_data

func _ready():
	pass
	


func _on_pressed() -> void:
	if RecursosGlobais.moeda >= item.preco:
		RecursosGlobais.moeda -= item.preco
		if item.Nome == "Cara Bonito":
			RecursosGlobais.vidaMax += item.valor_efeito
			RecursosGlobais.vidaAtual += item.valor_efeito
			print("vida maxima", RecursosGlobais.vidaMax)
		elif item.Nome == "Teste1":
			RecursosGlobais.dano += item.valor_efeito
			print("Dano: ", RecursosGlobais.dano)
		elif item.Nome == "Teste2":
			RecursosGlobais.velo_proje += item.valor_efeito
			print("Velocidade da bala: ", RecursosGlobais.velo_proje)
	visible = false

func atualizar_visual():
	$Label.text = str(item.preco)
	texture_normal = item.textura
		
