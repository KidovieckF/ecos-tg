extends CanvasLayer

var num_sorteado
var player
var sorte1 :item_data
var sorte2 :item_data
var sorte3 :item_data

@export var upgrades : Array[item_data]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("Players")
	sortear_upgrade()
	sorte1 = upgrades[num_sorteado]
	%Upgrade1.texture_normal = sorte1.textura
	%Nome1.text = sorte1.Nome
	%Descricao1.text = sorte1.efeito
	upgrades.remove_at(num_sorteado)
	sortear_upgrade()
	sorte2 = upgrades[num_sorteado]
	%Upgrade2.texture_normal = sorte2.textura
	%Nome2.text = sorte2.Nome
	%Descricao2.text = sorte2.efeito
	upgrades.remove_at(num_sorteado)
	sortear_upgrade()
	sorte3 = upgrades[num_sorteado]
	%Upgrade3.texture_normal = sorte3.textura
	%Nome3.text = sorte3.Nome
	%Descricao3.text = sorte3.efeito
	upgrades.remove_at(num_sorteado)

func sortear_upgrade():
	num_sorteado = randi_range(0, upgrades.size()-1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_upgrade_1_pressed() -> void:
	sorte1.aplicar_upgrade(player)

func _on_upgrade_2_pressed() -> void:
	sorte2.aplicar_upgrade(player)

func _on_upgrade_3_pressed() -> void:
	sorte3.aplicar_upgrade(player)
