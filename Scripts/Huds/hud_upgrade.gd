extends CanvasLayer

var num_sorteado : int
var player
var sorte1 : UpgradeData
var sorte2 : UpgradeData
var sorte3 : UpgradeData

var arma_alvo: ArmaRecurso = null
var upgrades_da_loja : Array[UpgradeData] = []
var eh_upgrade_de_arma : bool = false # Se for true (ex: a cada 5 níveis), foca em upgrades específicos

# Mapeamento dos upgrades específicos para cada arma
const UPGRADES_ESPECIFICOS = {
	"Buraco Negro": [
		"res://Recursos/Upgrades/Gravity_adicional.tres",
		"res://Recursos/Upgrades/Gravity_execute.tres"
	],
	"Laser": [
		"res://Recursos/Upgrades/Laser_continuo.tres",
		"res://Recursos/Upgrades/Laser_ricochete.tres"
	],
	"Circulo de Fogo": [
		"res://Recursos/Upgrades/Explosao_FOGO.tres",
		"res://Recursos/Upgrades/Fogo_espalha.tres",
		"res://Recursos/Upgrades/Fogo_crescimento.tres",
		"res://Recursos/Upgrades/Fogo_limite.tres",
		"res://Recursos/Upgrades/Fogo_tempoVida.tres"
	],
	"Missil": [
		"res://Recursos/Upgrades/Teleguiado.tres",
		"res://Recursos/Upgrades/Missil_explosivo.tres",
		"res://Recursos/Upgrades/Missil_orbital.tres"
	],
	"Terremoto": [
		"res://Recursos/Upgrades/Terremoto_andar.tres",
		"res://Recursos/Upgrades/Terremoto_DanoTick.tres",
		"res://Recursos/Upgrades/Terremoto_slow.tres",
		"res://Recursos/Upgrades/Terremoto_stun.tres"
	]
}

const DADOS_UPGRADES = {
	# --- Buraco Negro ---
	"gravity_adicional": {
		"nome": "Buraco Negro Extra",
		"desc": "+1 Buraco Negro simultâneo em campo.",
		"limite": 3
	},
	"gravity_execute": {
		"nome": "Execução Gravitacional",
		"desc": "Executa inimigos com vida baixa (aumenta o limiar a cada abate).",
		"limite": 1
	},
	# --- Laser ---
	"laser_continuo": {
		"nome": "Laser Contínuo",
		"desc": "Converte o disparo em um feixe contínuo de energia devastador.",
		"limite": 1
	},
	"laser_ricochete": {
		"nome": "Ricochete Elétrico",
		"desc": "O feixe ricocheteia entre inimigos próximos.",
		"limite": 1
	},
	# --- Círculo de Fogo ---
	"explosao": {
		"nome": "Explosão Ígnea",
		"desc": "Inimigos em chamas explodem em área ao morrer.",
		"limite": 1
	},
	"fogo_espalha": {
		"nome": "Fogo Alastrador",
		"desc": "Chamas propagam-se para inimigos próximos ao morrer.",
		"limite": 1
	},
	"fogo_crescimento": {
		"nome": "Expansão de Fogo",
		"desc": "Aumenta a velocidade de crescimento dos anéis.",
		"limite": 3
	},
	"fogo_limite": {
		"nome": "Círculos Adicionais",
		"desc": "+2 círculos de fogo simultâneos permitidos.",
		"limite": 3
	},
	"fogo_tempoVida": {
		"nome": "Chama Duradoura",
		"desc": "Aumenta o tempo de duração das chamas em campo.",
		"limite": 3
	},
	# --- Míssil ---
	"Teleguiado": {
		"nome": "Míssil Guiado",
		"desc": "Mísseis perseguem os inimigos mais próximos.",
		"limite": 1
	},
	"missil_explosao": {
		"nome": "Ogiva Explosiva",
		"desc": "Mísseis causam dano em área estendido ao detonar.",
		"limite": 3
	},
	"missil_orbital": {
		"nome": "Mísseis Orbitais",
		"desc": "Mísseis orbitam ao redor do jogador protegendo-o.",
		"limite": 1
	},
	# --- Terremoto ---
	"terremoto_passos": {
		"nome": "Passos Sísmicos",
		"desc": "Cria abalos sísmicos no chão enquanto você se move.",
		"limite": 1
	},
	"terremoto_danotick": {
		"nome": "Impacto Profundo",
		"desc": "Aumenta o dano periódico causado pelas fissuras.",
		"limite": 3
	},
	"slow": {
		"nome": "Tremor Retardante",
		"desc": "Inimigos na área do tremor têm sua velocidade reduzida.",
		"limite": 1
	},
	"stun": {
		"nome": "Abalo Estonteante",
		"desc": "Abalos têm chance de atordoar inimigos atingidos.",
		"limite": 1
	},
	# --- Gerais ---
	"Dano": {
		"nome": "Dano",
		"desc": "+Dano em todos os ataques da arma.",
		"limite": 10
	},
	"velocidade": {
		"nome": "Velocidade de Projétil",
		"desc": "+Velocidade de disparo dos projéteis.",
		"limite": 10
	},
	"tamanho": {
		"nome": "Área / Tamanho",
		"desc": "+Área de efeito e escala dos disparos.",
		"limite": 10
	},
	"+1Disparo": {
		"nome": "+1 Disparo",
		"desc": "+1 projétil lançado a cada disparo.",
		"limite": 5
	},
	"MultiDisparos": {
		"nome": "Multidisparo",
		"desc": "+1 rajada consecutiva de disparos.",
		"limite": 5
	},
	"bounce": {
		"nome": "Ricochete",
		"desc": "+1 ricochete em paredes e alvos.",
		"limite": 5
	},
	"penetracao": {
		"nome": "Penetração",
		"desc": "Projéteis atravessam os inimigos atingidos.",
		"limite": 1
	}
}

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Players")
	upgrades_da_loja.clear()
	
	var arma = arma_alvo if arma_alvo != null else (RunData.armas[0] if not RunData.armas.is_empty() else null)
	if arma == null:
		get_tree().paused = false
		queue_free()
		return
		
	var ativos = arma.upgrades_ativos
	
	var especificos_arma : Array[UpgradeData] = _carregar_especificos_da_arma(arma)
	
	var gerais_arma : Array[UpgradeData] = []
	for upg in arma.tipos_upgrade:
		if upg != null and not especificos_arma.has(upg):
			gerais_arma.append(upg)
			
	var especificos_filtrados = _filtrar_pool(especificos_arma, ativos) # 👈 Filtrados
	var gerais_filtrados = _filtrar_pool(gerais_arma, ativos)
	
	if eh_upgrade_de_arma:
		if not especificos_filtrados.is_empty():
			upgrades_da_loja = especificos_filtrados.duplicate()
		else:
			upgrades_da_loja = gerais_filtrados.duplicate()
	else:
		upgrades_da_loja = gerais_filtrados.duplicate()
	
	_configurar_slot(1, %Upgrade1, %Nome1, %Descricao1, arma)
	_configurar_slot(2, %Upgrade2, %Nome2, %Descricao2, arma)
	_configurar_slot(3, %Upgrade3, %Nome3, %Descricao3, arma)
	
	_configurar_hover_card(%Card1)
	_configurar_hover_card(%Card2)
	_configurar_hover_card(%Card3)
	
	_animar_entrada_cards()
	get_tree().paused = true


func _configurar_hover_card(card: Control) -> void:
	if card == null:
		return
	card.mouse_entered.connect(func():
		var tween = create_tween().set_parallel(true)
		tween.tween_property(card, "scale", Vector2(1.04, 1.04), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "modulate", Color(1.15, 1.15, 1.15), 0.1)
	)
	card.mouse_exited.connect(func():
		var tween = create_tween().set_parallel(true)
		tween.tween_property(card, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0), 0.1)
	)


func _animar_entrada_cards() -> void:
	var cards = [%Card1, %Card2, %Card3]
	for i in range(cards.size()):
		var card = cards[i]
		if card and card.visible:
			card.scale = Vector2(0.85, 0.85)
			card.modulate.a = 0.0
			var tween = create_tween().set_parallel(true)
			tween.tween_property(card, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i * 0.06)
			tween.tween_property(card, "modulate:a", 1.0, 0.18).set_delay(i * 0.06)


func _carregar_especificos_da_arma(arma: ArmaRecurso) -> Array[UpgradeData]:
	var lista : Array[UpgradeData] = []
	var caminhos = UPGRADES_ESPECIFICOS.get(arma.nome, [])
	for caminho in caminhos:
		if ResourceLoader.exists(caminho):
			var res = load(caminho)
			if res is UpgradeData:
				lista.append(res)
	return lista


func _filtrar_pool(pool: Array[UpgradeData], ativos: Array[UpgradeData]) -> Array[UpgradeData]:
	var resultado : Array[UpgradeData] = []
	
	for upg in pool:
		if upg == null:
			continue
			
		var limite_max = upg.limite
		if DADOS_UPGRADES.has(upg.efeito) and DADOS_UPGRADES[upg.efeito].has("limite"):
			limite_max = DADOS_UPGRADES[upg.efeito]["limite"]
			
		if limite_max > 0:
			var qtd = _contar_nivel_atual(upg, ativos)
			if qtd >= limite_max:
				continue
				
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
			
		resultado.append(upg)
		
	return resultado


func _contar_nivel_atual(upg: UpgradeData, ativos: Array[UpgradeData]) -> int:
	var qtd = 0
	for a in ativos:
		if a.resource_path == upg.resource_path or (a.efeito != "" and a.efeito == upg.efeito):
			qtd += 1
	return qtd


func _configurar_slot(indice: int, botao: TextureButton, lbl_nome: Label, lbl_desc: Label, arma: ArmaRecurso) -> void:
	var card = get_node_or_null("%%Card%d" % indice)
	if upgrades_da_loja.is_empty():
		if card:
			card.visible = false
		botao.visible = false
		lbl_nome.visible = false
		lbl_desc.visible = false
		return
		
	if card:
		card.visible = true
		
	sortear_upgrade()
	var sorte = upgrades_da_loja[num_sorteado]
	upgrades_da_loja.remove_at(num_sorteado)
	
	match indice:
		1: sorte1 = sorte
		2: sorte2 = sorte
		3: sorte3 = sorte
		
	if sorte.textura != null:
		botao.texture_normal = sorte.textura
	elif arma.textura != null:
		botao.texture_normal = arma.textura
		
	var dados = DADOS_UPGRADES.get(sorte.efeito, {})
	var nome_base = dados.get("nome", sorte.efeito)
	var desc_base = dados.get("desc", sorte.efeito)
	var limite_max = dados.get("limite", sorte.limite)
	
	var nivel_atual = _contar_nivel_atual(sorte, arma.upgrades_ativos)
	var proximo_nivel = nivel_atual + 1
	
	var str_nivel = "Nv. %d" % proximo_nivel
	if limite_max > 0:
		str_nivel = "Nv. %d/%d" % [proximo_nivel, limite_max]
		
	if nivel_atual == 0:
		lbl_nome.text = "%s\n[NOVO - %s]" % [nome_base, str_nivel]
	else:
		lbl_nome.text = "%s\n[%s]" % [nome_base, str_nivel]
		
	lbl_desc.text = desc_base
	lbl_nome.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART


func sortear_upgrade():
	num_sorteado = randi_range(0, upgrades_da_loja.size() - 1)


func _on_upgrade_1_pressed() -> void:
	_aplicar_upgrade(sorte1)

func _on_upgrade_2_pressed() -> void:
	_aplicar_upgrade(sorte2)

func _on_upgrade_3_pressed() -> void:
	_aplicar_upgrade(sorte3)

func _aplicar_upgrade(upgrade_escolhido: UpgradeData) -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
	var arma = arma_alvo if arma_alvo != null else (RunData.armas[0] if not RunData.armas.is_empty() else null)
	
	if upgrade_escolhido != null and arma != null:
		arma.upgrades_ativos.append(upgrade_escolhido)
		if arma.has_method("calcular_upgrades"):
			arma.calcular_upgrades()
			
	get_tree().paused = false
	queue_free()
