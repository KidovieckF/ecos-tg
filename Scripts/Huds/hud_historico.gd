extends Control

var slot_artefato_scene = preload("res://Cenas/Huds/slot_artefato.tscn")

@onready var container_margem = $GridContainer/Panel/MarginContainer
@onready var card_modelo = $GridContainer/Panel/MarginContainer/Panel

func _ready() -> void:
	carregar_lista_historico()
	adicionar_botao_voltar()


func carregar_lista_historico() -> void:
	var historico = SaveManager.obter_historico_runs()
	
	card_modelo.visible = false
	
	var scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container_margem.add_child(scroll)
	
	var vbox_lista = VBoxContainer.new()
	vbox_lista.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox_lista.add_theme_constant_override("separation", 14)
	scroll.add_child(vbox_lista)
	
	if historico.is_empty():
		var lbl_vazio = Label.new()
		lbl_vazio.text = "Nenhuma partida finalizada no histórico ainda.\nJogue uma run para ver suas estatísticas e seeds aqui!"
		lbl_vazio.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl_vazio.add_theme_font_size_override("font_size", 20)
		vbox_lista.add_child(lbl_vazio)
		return
		
	for run_data in historico:
		criar_card_run(vbox_lista, run_data)


func criar_card_run(pai: Node, dados: Dictionary) -> void:
	var novo_card = card_modelo.duplicate()
	novo_card.visible = true
	pai.add_child(novo_card)
	
	var lbl_num_run = novo_card.find_child("NumRun", true, false)
	if lbl_num_run:
		var resultado = dados.get("resultado", "Derrota")
		var cor_resultado = "[color=green]VITÓRIA[/color]" if resultado == "Vitória" else "[color=red]DERROTA[/color]"
		var seed_num = str(dados.get("seed", 0))
		lbl_num_run.text = "Run #" + str(dados.get("numero", 1)) + "  |  Seed: " + seed_num + "  (" + resultado + ")"
		if resultado == "Vitória":
			lbl_num_run.modulate = Color(0.4, 1.0, 0.4)
		else:
			lbl_num_run.modulate = Color(1.0, 0.5, 0.5)

	var lbl_inimigos = novo_card.find_child("InimigosMorte", true, false)
	if lbl_inimigos:
		lbl_inimigos.text = "Inimigos Mortos: " + str(dados.get("inimigos", 0))

	var lbl_tempo = novo_card.find_child("TempoRun", true, false)
	if lbl_tempo:
		lbl_tempo.text = "Tempo: " + str(dados.get("tempo", "00:00")) + "  |  Andar: " + str(dados.get("andar", 1))

	var lbl_dano = novo_card.find_child("DanoCausado", true, false)
	if lbl_dano:
		lbl_dano.text = "Dano Causado: " + str(dados.get("dano", 0))

	var lbl_artefatos = novo_card.find_child("Artefatos", true, false)
	if lbl_artefatos:
		lbl_artefatos.text = "Artefatos Coletados:"

	var grid_inventario = novo_card.find_child("InventarioGrid", true, false)
	if grid_inventario:
		var contagem_paths = {}
		for art_path in dados.get("artefatos", []):
			contagem_paths[art_path] = contagem_paths.get(art_path, 0) + 1
			
		for art_path in contagem_paths.keys():
			if ResourceLoader.exists(art_path):
				var art = load(art_path)
				if art:
					var qtd = contagem_paths[art_path]
					var slot = slot_artefato_scene.instantiate()
					slot.texture = art.icone
					
					if qtd > 1:
						slot.tooltip_text = "%s (x%d)\n%s" % [art.nome, qtd, art.descricao]
						
						var badge = Label.new()
						badge.text = str(qtd)
						badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
						badge.offset_left = -20
						badge.offset_top = -2
						badge.offset_right = -2
						badge.offset_bottom = 16
						badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
						badge.add_theme_font_size_override("font_size", 12)
						badge.add_theme_color_override("font_color", Color(1.0, 0.9, 0.2)) # Amarelo ouro
						badge.add_theme_color_override("font_outline_color", Color.BLACK)
						badge.add_theme_constant_override("outline_size", 4)
						slot.add_child(badge)
					else:
						slot.tooltip_text = art.nome + "\n" + art.descricao
						
					grid_inventario.add_child(slot)


func adicionar_botao_voltar() -> void:
	var btn_voltar = Button.new()
	btn_voltar.text = "Voltar ao Menu"
	btn_voltar.custom_minimum_size = Vector2(170, 40)
	btn_voltar.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	btn_voltar.offset_left = -190
	btn_voltar.offset_top = -58
	btn_voltar.offset_right = -20
	btn_voltar.offset_bottom = -18
	
	var style_btn = StyleBoxFlat.new()
	style_btn.bg_color = Color(0.18, 0.2, 0.28, 0.95)
	style_btn.border_color = Color(0.78, 0.63, 0.34, 0.9)
	style_btn.set_border_width_all(1)
	style_btn.set_corner_radius_all(8)
	btn_voltar.add_theme_stylebox_override("normal", style_btn)
	btn_voltar.add_theme_color_override("font_color", Color(1, 1, 1))
	btn_voltar.add_theme_color_override("font_hover_color", Color(0.98, 0.88, 0.55))
	
	btn_voltar.pressed.connect(func():
		AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
		get_tree().change_scene_to_file("res://Cenas/Mundo/Menu_inicial.tscn")
	)
	add_child(btn_voltar)
