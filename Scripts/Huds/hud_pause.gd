extends CanvasLayer

var slot_artefato = preload("res://Cenas/Huds/slot_artefato.tscn")
var cena_configs = preload("res://Cenas/Huds/tela_configuracoes.tscn")

func _ready() -> void:
	RunData.inventario_atualizado.connect(atualizar_inventario)
	atualizar_inventario()
	get_tree().paused = true
	atualizar_estatisticas()


func atualizar_estatisticas() -> void:
	if %VidaMax:
		%VidaMax.text = "  Vida Máxima: %d" % RunData.vida_max
	if %DanoRed:
		%DanoRed.text = "  Redução de Dano: %.1f%%" % (RunData.dano_reducao * 100.0)
	if %Dano:
		%Dano.text = "  Multiplicador de Dano: x%.2f" % RunData.dano_multiplicador
	if %ChanceCrit:
		%ChanceCrit.text = "  Chance de Crítico: %.1f%%" % (RunData.chance_critico * 100.0)
	if %DanoCrit:
		%DanoCrit.text = "  Dano Crítico: x%.2f" % RunData.dano_critico
	if %AtkSpeed:
		%AtkSpeed.text = "  Velocidade de Ataque: x%.2f" % RunData.mult_de_atk_speed
	if %Speed:
		%Speed.text = "  Velocidade: %.0f" % RunData.speed_calculado
	if %Dificuldade:
		%Dificuldade.text = "  Dificuldade: %s" % str(RunData.dificuldade)
		
	#Cantor superior esquerdo
	var player = get_tree().get_first_node_in_group("Players")
	var nv_player = player.nivel if player else RunData.nivel
	var nome_player = player.personagem.nome if (player and player.personagem) else "Alice"
	
	if has_node("%NivelPlayer"):
		%NivelPlayer.text = "  👤 %s: Nv. %d" % [nome_player, nv_player]
		
	if has_node("%NivelArma1") and RunData.armas[0]:
		%NivelArma1.text = "  ⚔️ %s: Nv. %d" % [RunData.armas[0].nome, RunData.armas[0].nivel]
		
	if has_node("%NivelArma2"):
		if RunData.armas.size() > 1 and RunData.armas[1]:
			%NivelArma2.visible = true
			%NivelArma2.text = "  🗡️ %s: Nv. %d" % [RunData.armas[1].nome, RunData.armas[1].nivel]
		else:
			%NivelArma2.visible = false


func _on_menu_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	SaveManager.salvar_run_atual()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Cenas/Mundo/Menu_inicial.tscn")
	queue_free()


func _on_voltar_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().paused = false
	queue_free()


func atualizar_inventario():
	for child in %InventarioGrid.get_children():
		child.queue_free()
		
	var qtd_total = RunData.artefatos_coletados.size()
	if %TituloArtefatos:
		%TituloArtefatos.text = "ARTEFATOS (%d)" % qtd_total
		
	if qtd_total == 0:
		var lbl_vazio = Label.new()
		lbl_vazio.text = "Nenhum artefato ainda"
		lbl_vazio.modulate = Color(0.6, 0.6, 0.65, 0.8)
		%InventarioGrid.add_child(lbl_vazio)
		return

	var contagem = {}
	for artefato in RunData.artefatos_coletados:
		if artefato in contagem:
			contagem[artefato] += 1
		else:
			contagem[artefato] = 1

	for artefato in contagem.keys():
		var qtd = contagem[artefato]
		var slot_inventario = slot_artefato.instantiate()
		slot_inventario.texture = artefato.icone
		slot_inventario.custom_minimum_size = Vector2(42, 42)
		
		if qtd > 1:
			slot_inventario.tooltip_text = "%s (x%d)\n%s" % [artefato.nome, qtd, artefato.descricao]
			
			var badge = Label.new()
			badge.text = str(qtd)
			badge.set_anchors_preset(Control.PRESET_TOP_RIGHT)
			badge.offset_left = -20
			badge.offset_top = -2
			badge.offset_right = -2
			badge.offset_bottom = 16
			badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			badge.add_theme_font_size_override("font_size", 12)
			badge.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3)) # Amarelo ouro
			badge.add_theme_color_override("font_outline_color", Color.BLACK)
			badge.add_theme_constant_override("outline_size", 4)
			slot_inventario.add_child(badge)
		else:
			slot_inventario.tooltip_text = "%s\n%s" % [artefato.nome, artefato.descricao]

		%InventarioGrid.add_child(slot_inventario)


func _on_configuracoes_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	var tela = cena_configs.instantiate()
	add_child(tela)
