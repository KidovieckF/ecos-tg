extends CanvasLayer

#Upgrade
var upg_de_dano = preload("res://Recursos/Upgrades/Dano.tres")
var upg_de_speed = preload("res://Recursos/Upgrades/Speed.tres")
var upg_de_tamanho = preload("res://Recursos/Upgrades/Tamanho.tres")
var upg_de_multidisparo = preload("res://Recursos/Upgrades/Multidisparo.tres")
var upg_de_bounce = preload("res://Recursos/Upgrades/Bounce.tres")
var upg_de_pentracao = preload("res://Recursos/Upgrades/Penetracao.tres")
var upg_de_disparos = preload("res://Recursos/Upgrades/Disparos.tres")
var qnt_dano = 0
var qnt_speed = 0
var qnt_tamanho = 0
var qnt_multDisparo = 0
var qnt_bounce = 0
var qnt_penetracao = 0
var qnt_disparos = 0

var art_dano = preload("res://Recursos/Artefatos/Teste_dano.tres")

var pagina = 1
@export var armas : Array[ArmaRecurso] = []
@export var artefatos : Array[Artefato_data] = []

func _ready() -> void:
	var popup = %ArtefatosMenu.get_popup()
	popup.id_pressed.connect(_on_item_pressed)
	
	for i in range(%ArmaButton.item_count):
		if %ArmaButton.get_item_text(i) == RunData.armas[0].nome:
			%ArmaButton.selected = i
			break

	
	for upgrade in RunData.armas[0].upgrades_ativos:
		if upgrade.efeito == "Dano":
			qnt_dano += 1 
		if upgrade.efeito == "velocidade":
			qnt_speed += 1 
		if upgrade.efeito == "tamanho":
			qnt_tamanho += 1 
		if upgrade.efeito == "+1Disparo":
			qnt_disparos += 1 
		if upgrade.efeito == "MultiDisparos":
			qnt_multDisparo += 1 
		if upgrade.efeito == "bounce":
			qnt_bounce += 1
		if upgrade.efeito == "penetracao":
			%PenetracaoToggle.toggled
			
		%DanoLine.text = str(qnt_dano)
		%SpeedLine.text = str(qnt_speed)
		%ProjLine.text = str(qnt_disparos)
		%DisparoLine.text = str(qnt_multDisparo)
		%TamanhoLine.text = str(qnt_tamanho)
		%BounceLine.text = str(qnt_bounce)

		%UltLabel.text = "Medidor da ultimate Maximo de:" + str(RunData.barra_ultimate)
		
func _process(delta: float) -> void:
	if pagina > 3:
		pagina = 3
	
	if pagina == 1:
		%Pagina1.visible = true
		%Pagina2.visible = false
		%Pagina3.visible = false
	elif pagina == 2:
		%Pagina1.visible = false
		%Pagina2.visible = true
		%Pagina3.visible = false
	elif pagina == 3: 
		%Pagina1.visible = false
		%Pagina2.visible = false
		%Pagina3.visible = true
		
	if pagina > 1:
		%Voltar.visible = true
	else:
		%Voltar.visible = false


func _on_proximo_pressed() -> void:
	pagina += 1

func _on_voltar_pressed() -> void:
	pagina -= 1
	


func _on_arma_button_item_selected(index: int) -> void:
	var arma_escolhida = armas[index]
	RunData.armas[0] = arma_escolhida


func _on_item_pressed(id: int):
	match id:
		0:
			RunData.adicionar_artefato(art_dano)
		1:
			print("Você clicou em Carregar Jogo!")
		2:
			print("Você clicou em Sair. Fechando...")
			get_tree().quit()

func _on_dano_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "Dano":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_dano)
	RunData.armas[0].calcular_upgrades()

	


func _on_speed_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "velocidade":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_speed)
	RunData.armas[0].calcular_upgrades()



func _on_proj_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "+1Disparo":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_disparos)
	RunData.armas[0].calcular_upgrades()



func _on_disparo_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "MultiDisparos":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_multidisparo)
	RunData.armas[0].calcular_upgrades()



func _on_tamanho_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "tamanho":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_tamanho)
	RunData.armas[0].calcular_upgrades()



func _on_bounce_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "bounce":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_bounce)
	RunData.armas[0].calcular_upgrades()

func _on_ult_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	RunData.barra_ultimate_atual = quantidade
	print("Quantidade da ultimate", RunData.barra_ultimate_atual)

func _on_penetracao_toggle_toggled(toggled_on: bool) -> void:
	RunData.armas[0].upgrades_ativos.append(upg_de_pentracao)
	RunData.armas[0].calcular_upgrades()


func _on_fechar_pressed() -> void:
	get_tree().paused = false
	queue_free()
