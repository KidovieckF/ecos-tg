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
		
	var qtd_artefatos = RunData.artefatos_coletados.size()
	if %TituloArtefatos:
		%TituloArtefatos.text = "ARTEFATOS (%d)" % qtd_artefatos
		
	if qtd_artefatos == 0:
		var lbl_vazio = Label.new()
		lbl_vazio.text = "Nenhum artefato ainda"
		lbl_vazio.modulate = Color(0.6, 0.6, 0.65, 0.8)
		%InventarioGrid.add_child(lbl_vazio)
		return
		
	for artefato in RunData.artefatos_coletados:
		var slot_inventario = slot_artefato.instantiate()
		slot_inventario.tooltip_text = "%s\n%s" % [artefato.nome, artefato.descricao]
		slot_inventario.texture = artefato.icone
		slot_inventario.custom_minimum_size = Vector2(42, 42)
		%InventarioGrid.add_child(slot_inventario)


func _on_configuracoes_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	var tela = cena_configs.instantiate()
	add_child(tela)
