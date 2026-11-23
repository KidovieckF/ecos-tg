extends CanvasLayer

@export var armas : Array[ArmaRecurso] = []
@export var artefatos : Array[Artefato_data] = []

var sorte1 : Artefato_data
var sorte2 : Artefato_data
var sorteArma : ArmaRecurso

var sorteadoArma : int = 0
var tempo_aberto : float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	atualizar_display_dinheiro()

	# 1. Carregar Artefato 1
	sorte1 = RunData.sortear_artefato_por_pesos(RunData.PESOS_LOJA)
	if sorte1 != null:
		%ArtNome1.text = sorte1.nome
		%ArtefatoBtn.texture_normal = sorte1.icone
		%ArtPreco1.text = "$" + str(sorte1.preco)
		%ArtefatoBtn.tooltip_text = "%s\n%s" % [sorte1.nome, sorte1.descricao]
		if %ArtefatoCard1:
			%ArtefatoCard1.visible = true
	else:
		if %ArtefatoCard1:
			%ArtefatoCard1.visible = false

	# 2. Carregar Artefato 2
	var tentativas = 0
	sorte2 = RunData.sortear_artefato_por_pesos(RunData.PESOS_LOJA)
	while sorte2 == sorte1 and RunData.artefatos_disponiveis.size() > 1 and tentativas < 10:
		sorte2 = RunData.sortear_artefato_por_pesos(RunData.PESOS_LOJA)
		tentativas += 1
		
	if sorte2 != null and sorte2 != sorte1:
		%ArtNome2.text = sorte2.nome
		%ArtefatoBtn2.texture_normal = sorte2.icone
		%ArtPreco3.text = "$" + str(sorte2.preco)
		%ArtefatoBtn2.tooltip_text = "%s\n%s" % [sorte2.nome, sorte2.descricao]
		if %ArtefatoCard2:
			%ArtefatoCard2.visible = true
	else:
		if %ArtefatoCard2:
			%ArtefatoCard2.visible = false

	# 3. Carregar Arma
	var mostrar_arma = randi_range(0, 1)
	if mostrar_arma == 1 and armas.size() > 0:
		sortear_arma()
		sorteArma = armas[sorteadoArma]
		%PrecoArma.text = "$" + str(sorteArma.preco)
		%DescricaoArma.text = str(sorteArma.nome)
		%ArmaBtn.texture_normal = sorteArma.textura
		%ArmaBtn.tooltip_text = sorteArma.nome
		if %ArmaContainer:
			%ArmaContainer.visible = true
	else:
		if %ArmaContainer:
			%ArmaContainer.visible = false

	_configurar_hover_card(%ArmaContainer)
	_configurar_hover_card(%ArtefatoCard1)
	_configurar_hover_card(%ArtefatoCard2)
	_animar_entrada_cards()


func _configurar_hover_card(card: Control) -> void:
	if card == null:
		return
	card.mouse_entered.connect(func():
		var tween = create_tween().set_parallel(true)
		tween.tween_property(card, "scale", Vector2(1.03, 1.03), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "modulate", Color(1.12, 1.12, 1.12), 0.1)
	)
	card.mouse_exited.connect(func():
		var tween = create_tween().set_parallel(true)
		tween.tween_property(card, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(card, "modulate", Color.WHITE, 0.1)
	)


func _animar_entrada_cards() -> void:
	var cards = [%ArmaContainer, %ArtefatoCard1, %ArtefatoCard2]
	for i in range(cards.size()):
		var card = cards[i]
		if card and card.visible:
			card.scale = Vector2(0.9, 0.9)
			card.modulate.a = 0.0
			var tween = create_tween().set_parallel(true)
			tween.tween_property(card, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i * 0.06)
			tween.tween_property(card, "modulate:a", 1.0, 0.18).set_delay(i * 0.06)


func atualizar_display_dinheiro() -> void:
	if %DinheiroLabel:
		%DinheiroLabel.text = "%d Moedas" % obter_dinheiro()


func _process(delta: float) -> void:
	tempo_aberto += delta


func _input(event: InputEvent) -> void:
	if tempo_aberto < 0.15:
		return

	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_E:
			get_viewport().set_input_as_handled()
			fechar()
	elif event.is_action_pressed("Interagir") or event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		fechar()


func fechar() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().paused = false
	queue_free()


func sortear_arma() -> void:
	if armas.size() > 0:
		sorteadoArma = randi_range(0, armas.size() - 1)


func obter_dinheiro() -> int:
	return RecursosGlobais.moeda + RunData.moeda_run


func gastar_dinheiro(valor: int) -> void:
	if RecursosGlobais.moeda >= valor:
		RecursosGlobais.gastar_moeda(valor)
	else:
		var restante = valor - RecursosGlobais.moeda
		RecursosGlobais.moeda = 0
		RunData.moeda_run = max(0, RunData.moeda_run - restante)
	
	atualizar_display_dinheiro()
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud and hud.has_method("atualizar_dinheiro"):
		hud.atualizar_dinheiro()


func piscar_vermelho(alvo: Control) -> void:
	if alvo == null:
		return
	var tween = create_tween().set_loops(3).bind_node(self)
	tween.tween_property(alvo, "modulate", Color(1.6, 0.4, 0.4), 0.1)
	tween.tween_property(alvo, "modulate", Color.WHITE, 0.1)


func _on_arma_btn_pressed() -> void:
	if sorteArma == null:
		return

	if obter_dinheiro() >= sorteArma.preco:
		gastar_dinheiro(sorteArma.preco)
		AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
		
		if RunData.armas[0] == null:
			RunData.armas[0] = sorteArma
		elif RunData.armas[1] == null:
			RunData.armas[1] = sorteArma
		else:
			RunData.armas[0] = sorteArma
			
		var p = get_tree().get_first_node_in_group("Players")
		if p and "arma" in p:
			p.arma = RunData.armas[0]

		%ArmaBtn.disabled = true
		%PrecoArma.text = "Adquirido"
		%PrecoArma.modulate = Color(0.4, 1.0, 0.5)
		%ComprarBtn.text = "Comprado"
		%ComprarBtn.disabled = true
		if %ArmaContainer:
			%ArmaContainer.modulate = Color(0.7, 0.7, 0.75, 0.85)
		sorteArma = null
	else:
		piscar_vermelho(%ArmaContainer)


func _on_artefato_btn_pressed() -> void:
	if sorte1 == null:
		return

	if obter_dinheiro() >= sorte1.preco:
		gastar_dinheiro(sorte1.preco)
		AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
		RunData.adicionar_artefato(sorte1)
		
		%ArtefatoBtn.disabled = true
		%ArtPreco1.text = "Adquirido"
		%ArtPreco1.modulate = Color(0.4, 1.0, 0.5)
		if %ComprarBtnArt1:
			%ComprarBtnArt1.text = "Comprado"
			%ComprarBtnArt1.disabled = true
		if %ArtefatoCard1:
			%ArtefatoCard1.modulate = Color(0.7, 0.7, 0.75, 0.85)
		sorte1 = null
	else:
		piscar_vermelho(%ArtefatoCard1)


func _on_artefato_btn_2_pressed() -> void:
	if sorte2 == null:
		return

	if obter_dinheiro() >= sorte2.preco:
		gastar_dinheiro(sorte2.preco)
		AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
		RunData.adicionar_artefato(sorte2)
		
		%ArtefatoBtn2.disabled = true
		%ArtPreco3.text = "Adquirido"
		%ArtPreco3.modulate = Color(0.4, 1.0, 0.5)
		if %ComprarBtnArt2:
			%ComprarBtnArt2.text = "Comprado"
			%ComprarBtnArt2.disabled = true
		if %ArtefatoCard2:
			%ArtefatoCard2.modulate = Color(0.7, 0.7, 0.75, 0.85)
		sorte2 = null
	else:
		piscar_vermelho(%ArtefatoCard2)
