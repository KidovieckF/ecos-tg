extends CanvasLayer

@export var catalogo_pocoes : Array[PocaoData] = []

@onready var slot1 = %Slot1
@onready var slot2 = %Slot2
@onready var slot3 = %Slot3

var pocoes_ofertadas : Array[PocaoData] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	atualizar_display_dinheiro()
	_gerar_ofertas()
	_configurar_hover_card(slot1)
	_configurar_hover_card(slot2)
	_configurar_hover_card(slot3)
	_animar_entrada_cards()


func atualizar_display_dinheiro() -> void:
	if %DinheiroLabel:
		var total = RecursosGlobais.moeda + RunData.moeda_run
		%DinheiroLabel.text = "%d Moedas" % total


func _gerar_ofertas() -> void:
	pocoes_ofertadas.clear()
	
	var pool = catalogo_pocoes.duplicate()
	pool.shuffle()
	
	for i in range(min(3, pool.size())):
		pocoes_ofertadas.append(pool[i])
		
	_configurar_slot(slot1, 0)
	_configurar_slot(slot2, 1)
	_configurar_slot(slot3, 2)


func _configurar_slot(slot_node: Control, indice: int) -> void:
	if slot_node == null:
		return
		
	if indice >= pocoes_ofertadas.size():
		slot_node.visible = false
		return
		
	var pocao = pocoes_ofertadas[indice]
	slot_node.visible = true
	
	var lbl_nome = slot_node.get_node_or_null("Margin/VBox/Nome") if slot_node.has_node("Margin/VBox/Nome") else slot_node.get_node_or_null("Nome")
	var lbl_desc = slot_node.get_node_or_null("Margin/VBox/Descricao") if slot_node.has_node("Margin/VBox/Descricao") else slot_node.get_node_or_null("Descricao")
	var btn_icone = slot_node.get_node_or_null("Margin/VBox/Frame/Icone") if slot_node.has_node("Margin/VBox/Frame/Icone") else slot_node.get_node_or_null("Icone")
	var btn_comprar = slot_node.get_node_or_null("Margin/VBox/BtnComprar") if slot_node.has_node("Margin/VBox/BtnComprar") else slot_node.get_node_or_null("BtnComprar")
	
	var duracao_txt = " (%d salas de combate)" % pocao.salas_duracao if pocao.salas_duracao > 0 else " (Instantâneo)"
	var texto_tooltip = "%s\n%s\nDuração: %s" % [pocao.nome, pocao.descricao, duracao_txt]
	
	slot_node.tooltip_text = texto_tooltip
	
	if lbl_nome:
		lbl_nome.text = pocao.nome
		
	if lbl_desc:
		lbl_desc.text = "%s%s" % [pocao.descricao, duracao_txt]
		lbl_desc.visible = true
		
	if btn_icone:
		btn_icone.tooltip_text = texto_tooltip
		if pocao.icone != null:
			if btn_icone is TextureButton:
				btn_icone.texture_normal = pocao.icone
			elif btn_icone is TextureRect:
				btn_icone.texture = pocao.icone
			
	if btn_comprar:
		btn_comprar.text = "$%d" % pocao.preco
		if not btn_comprar.pressed.is_connected(_on_comprar_pressionado):
			btn_comprar.pressed.connect(_on_comprar_pressionado.bind(pocao, btn_comprar, slot_node))


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
	var cards = [slot1, slot2, slot3]
	for i in range(cards.size()):
		var card = cards[i]
		if card and card.visible:
			card.scale = Vector2(0.9, 0.9)
			card.modulate.a = 0.0
			var tween = create_tween().set_parallel(true)
			tween.tween_property(card, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(i * 0.06)
			tween.tween_property(card, "modulate:a", 1.0, 0.18).set_delay(i * 0.06)


func _on_comprar_pressionado(pocao: PocaoData, botao_compra: Button, slot_node: Control = null) -> void:
	var total_dinheiro = RecursosGlobais.moeda + RunData.moeda_run
	
	if total_dinheiro < pocao.preco:
		var tween = create_tween().set_loops(3).bind_node(self)
		tween.tween_property(botao_compra, "modulate", Color(1.6, 0.4, 0.4), 0.1)
		tween.tween_property(botao_compra, "modulate", Color.WHITE, 0.1)
		return
		
	if RecursosGlobais.moeda >= pocao.preco:
		RecursosGlobais.gastar_moeda(pocao.preco)
	else:
		var restante = pocao.preco - RecursosGlobais.moeda
		RecursosGlobais.moeda = 0
		RunData.moeda_run = max(0, RunData.moeda_run - restante)
		
	atualizar_display_dinheiro()
	var hud = get_tree().get_first_node_in_group("HUD")
	if hud and hud.has_method("atualizar_dinheiro"):
		hud.atualizar_dinheiro()

	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
	RunData.aplicar_pocao(pocao)
	
	botao_compra.disabled = true
	botao_compra.text = "Ativa"
	botao_compra.modulate = Color(0.4, 1.0, 0.5)
	if slot_node:
		slot_node.modulate = Color(0.7, 0.7, 0.75, 0.85)


func _on_button_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().paused = false
	queue_free()
