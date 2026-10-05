extends CanvasLayer

var num_sorteado
var player
var sorte1 : UpgradeData
var sorte2 : UpgradeData
var sorte3 : UpgradeData

var upgrades_da_loja : Array[UpgradeData]
var eh_upgrade_de_arma : bool = false # O Player vai alterar isso na hora de instanciar!

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Players")
	upgrades_da_loja.clear()
	
	var pool_bruta : Array[UpgradeData] = []
	if eh_upgrade_de_arma:
		pool_bruta = RunData.armas[0].tipos_upgrade
	else:
		pool_bruta = RunData.upgrades_gerais_pool
		
	var ativos = RunData.armas[0].upgrades_ativos
	
	for upg in pool_bruta:

		if upg.limite > 0:
			var qtd = 0
			for a in ativos:
				if a.resource_path == upg.resource_path:
					qtd += 1
			if qtd >= upg.limite:
				continue

		# Exclusao da lista de upgrades incompativeis
		var bloqueado = false
		for excl in upg.excludentes:
			for a in ativos:
				if a.resource_path == excl.resource_path:
					bloqueado = true
					break
			if bloqueado: break
		
		if not bloqueado:
			for a in ativos:
				for excl in a.excludentes:
					if excl.resource_path == upg.resource_path:
						bloqueado = true
						break
				if bloqueado: break
				
		if bloqueado:
			continue 
		
		# Exclusao da lista de upgrades incompativeis com a arma
		var arma_proibida = false
		for arma in upg.armas_proibidas:
			if arma.resource_path == RunData.armas[0].resource_path:
				arma_proibida = true
				break
		if arma_proibida:
			continue
			
		upgrades_da_loja.append(upg)

	if upgrades_da_loja.size() > 0:
		sortear_upgrade()
		sorte1 = upgrades_da_loja[num_sorteado]
		%Upgrade1.texture_normal = sorte1.textura
		%Nome1.text = sorte1.efeito
		%Descricao1.text = sorte1.efeito
		upgrades_da_loja.remove_at(num_sorteado)
	else:
		%Upgrade1.visible = false
		
	if upgrades_da_loja.size() > 0:
		sortear_upgrade()
		sorte2 = upgrades_da_loja[num_sorteado]
		%Upgrade2.texture_normal = sorte2.textura
		%Nome2.text = sorte2.efeito
		%Descricao2.text = sorte2.efeito
		upgrades_da_loja.remove_at(num_sorteado)
	else:
		%Upgrade2.visible = false
		
	if upgrades_da_loja.size() > 0:
		sortear_upgrade()
		sorte3 = upgrades_da_loja[num_sorteado]
		%Upgrade3.texture_normal = sorte3.textura
		%Nome3.text = sorte3.efeito
		%Descricao3.text = sorte3.efeito
		upgrades_da_loja.remove_at(num_sorteado)
	else:
		%Upgrade3.visible = false

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
