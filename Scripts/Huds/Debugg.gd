extends CanvasLayer

#Upgrade
var upg_de_dano = preload("res://Recursos/Upgrades/Gerais/Dano.tres")
var upg_de_speed = preload("res://Recursos/Upgrades/Gerais/Speed.tres")
var upg_de_tamanho = preload("res://Recursos/Upgrades/Gerais/Tamanho.tres")
var upg_de_multidisparo = preload("res://Recursos/Upgrades/Gerais/Multidisparo.tres")
var upg_de_bounce = preload("res://Recursos/Upgrades/Gerais/Bounce.tres")
var upg_de_pentracao = preload("res://Recursos/Upgrades/Gerais/Penetracao.tres")
var upg_de_disparos = preload("res://Recursos/Upgrades/Gerais/Disparos.tres")
var upg_de_explosao_FOGO = preload("res://Recursos/Upgrades/Explosao_FOGO.tres")
var upg_de_bala_teleguiada = preload("res://Recursos/Upgrades/Teleguiado.tres")
var upg_de_missil_explosao = preload("res://Recursos/Upgrades/Missil_explosivo.tres")
var upg_de_missil_orbital = preload("res://Recursos/Upgrades/Missil_orbital.tres")
var upg_de_titan_andar = preload("res://Recursos/Upgrades/Terremoto_andar.tres")
var upg_de_titan_danotick = preload("res://Recursos/Upgrades/Terremoto_DanoTick.tres")
var upg_de_titan_slow = preload("res://Recursos/Upgrades/Terremoto_slow.tres")
var upg_de_titan_stun = preload("res://Recursos/Upgrades/Terremoto_stun.tres") 
var upg_de_fogo_limite = preload("res://Recursos/Upgrades/Fogo_limite.tres")
var upg_de_fogo_crescimento = preload("res://Recursos/Upgrades/Fogo_crescimento.tres")
var upg_de_fogo_tempovida = preload("res://Recursos/Upgrades/Fogo_tempoVida.tres")
var upg_de_fogo_espalha = preload("res://Recursos/Upgrades/Fogo_espalha.tres")
var upg_de_gravity_execute = preload("res://Recursos/Upgrades/Gravity_execute.tres")
var upg_de_gravity_adicional = preload("res://Recursos/Upgrades/Gravity_adicional.tres")
var upg_de_laser_ricochte = preload("res://Recursos/Upgrades/Laser_ricochete.tres")
var upg_de_laser_continuo = preload("res://Recursos/Upgrades/Laser_continuo.tres")
var qnt_dano = 0
var qnt_speed = 0
var qnt_tamanho = 0
var qnt_multDisparo = 0
var qnt_bounce = 0
var qnt_penetracao = 0
var qnt_disparos = 0
var qnt_explosao = 0
var qnt_missil_explosao = 0
var qnt_teleguiado = 0
var qnt_orbital = 0
var qnt_titan_andar = 0
var qnt_titan_danotick = 0
var qnt_titan_slow = 0
var qnt_titan_stun = 0
var qnt_fogo_limite = 0
var qnt_fogo_crescimento = 0
var qnt_fogo_tempo_vida = 0
var qnt_fogo_espalha = 0
var qnt_gravity_execute = 0
var qnt_gravity_adicional = 0
var qnt_laser_ricochete = 0
var qnt_laser_continuo = 0

var art_dano = preload("res://Recursos/Artefatos/Cristral_mana.tres")
var art_vida = preload("res://Recursos/Artefatos/Whey_Protein.tres")
var art_chanceCrit = preload("res://Recursos/Artefatos/Lente_contato.tres")
var art_vida_mult = preload("res://Recursos/Artefatos/O_suco.tres")
var art_atkS = preload("res://Recursos/Artefatos/Coldre_xerife.tres")
var art_armadura = preload("res://Recursos/Artefatos/Armadura_pesada.tres")
var art_cogumelo = preload("res://Recursos/Artefatos/Cogumelo.tres")
var art_cristal = preload("res://Recursos/Artefatos/Cristal_corrompido.tres")
var art_prensa = preload("res://Recursos/Artefatos/Prensa.tres")
var art_flor = preload("res://Recursos/Artefatos/Florzinha.tres")
var art_botina = preload("res://Recursos/Artefatos/Botina_Xerife.tres")
var art_oculos = preload("res://Recursos/Artefatos/Oculos_sol.tres")
var art_chapeu = preload("res://Recursos/Artefatos/Chapeu_cowboy.tres")
var art_egide = preload("res://Recursos/Artefatos/Egide.tres")


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
		if upgrade.efeito == "explosao": 
			qnt_explosao += 1 
		if upgrade.efeito == "Teleguiado": 
			qnt_teleguiado += 1
		if upgrade.efeito == "missil_explosao":
			qnt_missil_explosao += 1
		if upgrade.efeito == "missil_orbital":
			qnt_orbital += 1
		if upgrade.efeito == "terremoto_passos":
			qnt_titan_andar += 1
		if upgrade.efeito == "terremoto_danotick":
			qnt_titan_danotick += 1
		if upgrade.efeito == "slow":
			qnt_titan_slow += 1
		if upgrade.efeito == "stun":
			qnt_titan_stun += 1
		if upgrade.efeito == "fogo_limite":
			qnt_fogo_limite += 1
		if upgrade.efeito == "fogo_tempoVida":
			qnt_fogo_tempo_vida += 1
		if upgrade.efeito == "fogo_crescimento":
			qnt_fogo_crescimento += 1
		if upgrade.efeito == "fogo_espalha":
			qnt_fogo_espalha += 1
		if upgrade.efeito == "gravity_execute":
			qnt_gravity_execute += 1
		if upgrade.efeito == "gravity_adicional":
			qnt_gravity_adicional += 1
		if upgrade.efeito == "laser_ricochete":
			qnt_laser_ricochete += 1
		if upgrade.efeito == "laser_continuo":
			qnt_laser_continuo += 1
		if upgrade.efeito == "penetracao":
			%PenetracaoToggle.toggled
			
		%LaserRicocheteLine.text = str(qnt_laser_ricochete)
		%LaserContinuoLine.text = str(qnt_laser_continuo)
		%GravityAdicionalLine.text = str(qnt_gravity_adicional)
		%GravityExecuteLine.text = str(qnt_gravity_execute)
		%FogoEspalhaLine.text = str(qnt_fogo_espalha)
		%FogoLimiteLine.text = str(qnt_fogo_limite)
		%FogoCrescimentoLine.text = str(qnt_fogo_crescimento)
		%FogoTempoVidaLine.text = str(qnt_fogo_tempo_vida)
		%Titan_SlowLine.text = str(qnt_titan_slow)
		%Titan_StunLine.text = str(qnt_titan_stun)
		%Titan_DanoTickLine.text = str(qnt_titan_danotick)
		%Titan_andarLine.text = str(qnt_titan_andar)
		%OrbitalLine.text = str(qnt_orbital)
		%ExplosaoMissilLine.text = str(qnt_missil_explosao)
		%DanoLine.text = str(qnt_dano)
		%SpeedLine.text = str(qnt_speed)
		%ProjLine.text = str(qnt_disparos)
		%DisparoLine.text = str(qnt_multDisparo)
		%TamanhoLine.text = str(qnt_tamanho)
		%BounceLine.text = str(qnt_bounce)
		%ExplosaoLine.text = str(qnt_explosao)
		%TeleguiadoLine.text = str(qnt_teleguiado)
		
		%UltLabel.text = "Medidor da ultimate Maximo de:" + str(RunData.barra_ultimate)
		
func _process(delta: float) -> void:
	if pagina > 4:
		pagina = 4
	
	if pagina == 1:
		%Pagina1.visible = true
		%Pagina2.visible = false
		%Pagina3.visible = false
		%Pagina4.visible = false
	elif pagina == 2:
		%Pagina1.visible = false
		%Pagina2.visible = true
		%Pagina3.visible = false
		%Pagina4.visible = false
	elif pagina == 3: 
		%Pagina1.visible = false
		%Pagina2.visible = false
		%Pagina3.visible = true
		%Pagina4.visible = false
	elif pagina == 4: 
		%Pagina1.visible = false
		%Pagina2.visible = false
		%Pagina3.visible = false
		%Pagina4.visible = true
		
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
			RunData.adicionar_artefato(art_vida)
		2:
			RunData.adicionar_artefato(art_chanceCrit)
		3:
			RunData.adicionar_artefato(art_vida_mult)
		4:
			RunData.adicionar_artefato(art_atkS)
		5:
			RunData.adicionar_artefato(art_armadura)
		6: 
			RunData.adicionar_artefato(art_cogumelo)
		7:
			RunData.adicionar_artefato(art_cristal)
		8:
			RunData.adicionar_artefato(art_prensa)
		9:
			RunData.adicionar_artefato(art_flor)
		10:
			RunData.adicionar_artefato(art_botina)
		11:
			RunData.adicionar_artefato(art_oculos)
		12:
			RunData.adicionar_artefato(art_chapeu)
		13: 
			RunData.adicionar_artefato(art_egide)

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

func _on_explosao_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "explosao":
			lista_limpa.append(i)
			
	RunData.armas[0].upgrades_ativos = lista_limpa
	
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_explosao_FOGO)
		
	RunData.armas[0].calcular_upgrades()

func _on_teleguiado_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "Teleguiado":
			lista_limpa.append(i)
			
	RunData.armas[0].upgrades_ativos = lista_limpa
	
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_bala_teleguiada)
		
	RunData.armas[0].calcular_upgrades()
	
func _on_orbital_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "missil_orbital":
			lista_limpa.append(i)
			
	RunData.armas[0].upgrades_ativos = lista_limpa
	
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_missil_orbital)
		
	RunData.armas[0].calcular_upgrades()

func _on_titan_andar_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "terremoto_passos":
			lista_limpa.append(i)
			
	RunData.armas[0].upgrades_ativos = lista_limpa
	
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_titan_andar)
		
	RunData.armas[0].calcular_upgrades()

func _on_explosao_missil_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "missil_explosao":
			lista_limpa.append(i)
			
	RunData.armas[0].upgrades_ativos = lista_limpa
	
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_missil_explosao)
		
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

func _on_titan_dano_tick_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "terremoto_danotick":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_titan_danotick)
	RunData.armas[0].calcular_upgrades()

func _on_titan_slow_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "slow":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_titan_slow)
	RunData.armas[0].calcular_upgrades()


func _on_titan_stun_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "stun":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_titan_stun)
	RunData.armas[0].calcular_upgrades()

func _on_gravity_execute_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "gravity_execute":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_gravity_execute)
	RunData.armas[0].calcular_upgrades()

func _on_gravity_adicional_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "gravity_adicional":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_gravity_adicional)
	RunData.armas[0].calcular_upgrades()

func _on_fogo_limite_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "fogo_limite":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_fogo_limite)
	RunData.armas[0].calcular_upgrades()


func _on_fogo_crescimento_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "fogo_crescimento":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_fogo_crescimento)
	RunData.armas[0].calcular_upgrades()


func _on_fogo_tempo_vida_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "fogo_tempoVida":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_fogo_tempovida)
	RunData.armas[0].calcular_upgrades()

func _on_fogo_espalha_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "fogo_espalha":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_fogo_espalha)
	RunData.armas[0].calcular_upgrades()
	
	
func _on_laser_ricochete_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "laser_ricochete":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_laser_ricochte)
	RunData.armas[0].calcular_upgrades()


func _on_laser_continuo_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	var lista_limpa: Array[UpgradeData] = []
	for i in RunData.armas[0].upgrades_ativos:
		if i.efeito != "laser_continuo":
			lista_limpa.append(i)
	RunData.armas[0].upgrades_ativos = lista_limpa
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_laser_continuo)
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
