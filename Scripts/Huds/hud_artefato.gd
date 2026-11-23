extends CanvasLayer

@export var artefato : Artefato_data

var tempo_aberto : float = 0.0

func _ready() -> void:
	get_tree().paused = true
	if artefato != null:
		exibir_artefato(artefato)
	_animar_entrada()
	_configurar_hover_botoes()


func _process(delta: float) -> void:
	tempo_aberto += delta


func _input(event: InputEvent) -> void:
	if tempo_aberto < 0.2:
		return
		
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_E or event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			get_viewport().set_input_as_handled()
			_on_aceitar_btn_pressed()
		elif event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			_on_recusar_btn_pressed()


func _animar_entrada() -> void:
	var painel = $CenterContainer/Panel
	if painel:
		painel.scale = Vector2(0.85, 0.85)
		painel.modulate.a = 0.0
		var tween = create_tween().set_parallel(true)
		tween.tween_property(painel, "scale", Vector2.ONE, 0.22).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(painel, "modulate:a", 1.0, 0.18)


func _configurar_hover_botoes() -> void:
	for btn in [%AceitarBtn, %RecusarBtn]:
		if btn:
			btn.mouse_entered.connect(func():
				var tween = create_tween().set_parallel(true)
				tween.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_SINE)
				tween.tween_property(btn, "modulate", Color(1.15, 1.15, 1.15), 0.1)
			)
			btn.mouse_exited.connect(func():
				var tween = create_tween().set_parallel(true)
				tween.tween_property(btn, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE)
				tween.tween_property(btn, "modulate", Color.WHITE, 0.1)
			)


func exibir_artefato(artefato_cena : Artefato_data):
	artefato = artefato_cena
	if %Nome:
		%Nome.text = artefato.nome
	if %Textura:
		%Textura.texture = artefato.icone
	if %Descricao:
		%Descricao.text = artefato.descricao


func _on_aceitar_btn_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
	if artefato != null:
		RunData.adicionar_artefato(artefato)
	get_tree().paused = false
	queue_free()


func _on_recusar_btn_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	get_tree().paused = false
	queue_free()
