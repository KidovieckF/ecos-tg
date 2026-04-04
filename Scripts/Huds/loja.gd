extends CanvasLayer

var preco_rerrol = 1
@export var lista_item :Array[item_data]

func _ready() -> void:
	sortear_item()

func _on_but_fechar_pressed() -> void:
	queue_free()

func sortear_item():
	var item_sorteado1 = lista_item.pick_random()
	var item_sorteado2 = lista_item.pick_random()
	%Item1.visible = true
	%Item1.item = item_sorteado1
	%Preco.text = "Preço $" + str(%Item1.item.preco)
	%Item1.atualizar_visual()
	%Item2.visible = true
	%Item2.item = item_sorteado2
	%Preco2.text = "Preço $" + str(%Item2.item.preco)
	%Item2.atualizar_visual()


func _on_but_rerrol_pressed() -> void:
	sortear_item()
	preco_rerrol += 2
	%But_rerrol.text = "Rerrol: $" + str(preco_rerrol)
	
