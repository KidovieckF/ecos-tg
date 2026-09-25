extends CanvasLayer

var num_sorteado
var player
var sorte1 :UpgradeData
var sorte2 :UpgradeData
var sorte3 :UpgradeData

var upgrades : Array[UpgradeData] = RunData.armas[0].tipos_upgrade
var upgrades_da_loja : Array[UpgradeData]


func _ready() -> void:
	upgrades_da_loja = upgrades.duplicate()
	player = get_tree().get_first_node_in_group("Players")
	sortear_upgrade()
	sorte1 = upgrades_da_loja[num_sorteado]
	%Upgrade1.texture_normal = sorte1.textura
	%Nome1.text = sorte1.efeito
	%Descricao1.text = sorte1.efeito
	upgrades_da_loja.remove_at(num_sorteado)
	sortear_upgrade()
	sorte2 = upgrades_da_loja[num_sorteado]
	%Upgrade2.texture_normal = sorte2.textura
	%Nome2.text = sorte2.efeito
	%Descricao2.text = sorte2.efeito
	upgrades_da_loja.remove_at(num_sorteado)
	sortear_upgrade()
	sorte3 = upgrades_da_loja[num_sorteado]
	%Upgrade3.texture_normal = sorte3.textura
	%Nome3.text = sorte3.efeito
	%Descricao3.text = sorte3.efeito
	upgrades_da_loja.remove_at(num_sorteado)
	get_tree().paused = true

func sortear_upgrade():
	num_sorteado = randi_range(0, upgrades_da_loja.size()-1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_upgrade_1_pressed() -> void:
	print("Clicou no upgrade1")
	RunData.armas[0].upgrades_ativos.append(sorte1)
	RunData.armas[0].calcular_upgrades()
	get_tree().paused = false
	queue_free()

func _on_upgrade_2_pressed() -> void:
	print("Clicou no upgrade2")
	RunData.armas[0].upgrades_ativos.append(sorte2)
	RunData.armas[0].calcular_upgrades()
	get_tree().paused = false
	queue_free()
	
func _on_upgrade_3_pressed() -> void:
	print("Clicou no upgrade3")
	RunData.armas[0].upgrades_ativos.append(sorte3)
	RunData.armas[0].calcular_upgrades()
	get_tree().paused = false
	queue_free()
