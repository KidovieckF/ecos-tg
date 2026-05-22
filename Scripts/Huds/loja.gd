extends CanvasLayer

var preco_rerrol = 1
@export var lista_item :Array[item_data]

func _ready() -> void:
	sortear_upgrade()

func sortear_upgrade():
	var item_sorteado1 = lista_item.pick_random()
	var item_sorteado2 = lista_item.pick_random()
	%Item1.visible = true
	%Item1.item = item_sorteado1
	%Item1.atualizar_visual()
	%Item2.visible = true
	%Item2.item = item_sorteado2
	%Item2.atualizar_visual()


func _on_item_1_pressed() -> void:
	queue_free()


func _on_item_2_pressed() -> void:
	queue_free()
