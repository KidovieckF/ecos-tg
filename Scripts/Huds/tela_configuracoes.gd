extends CanvasLayer

var som_cooldown: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 10
	construir_interface()


func _process(delta: float) -> void:
	if som_cooldown > 0.0:
		som_cooldown -= delta


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_ESCAPE:
			get_viewport().set_input_as_handled()
			fechar()


func construir_interface() -> void:
	# Fundo escurecido semi-transparente
	var fundo = ColorRect.new()
	fundo.color = Color(0, 0, 0, 0.65)
	fundo.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(fundo)

	# Painel Central Estilizado
	var painel = Panel.new()
	painel.custom_minimum_size = Vector2(460, 480)
	painel.set_anchors_preset(Control.PRESET_CENTER)
	painel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	painel.grow_vertical = Control.GROW_DIRECTION_BOTH

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.24, 0.22, 0.28, 1.0)
	style.set_corner_radius_all(18)
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.79, 0.53, 0.34, 1.0)
	painel.add_theme_stylebox_override("panel", style)
	add_child(painel)

	# Container principal de margem
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 30)
	margin.add_theme_constant_override("margin_top", 25)
	margin.add_theme_constant_override("margin_right", 30)
	margin.add_theme_constant_override("margin_bottom", 25)
	painel.add_child(margin)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	margin.add_child(vbox)

	# Título
	var titulo = Label.new()
	titulo.text = "Configurações"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_font_size_override("font_size", 26)
	vbox.add_child(titulo)

	# 1. Slider Volume Master
	criar_slider_audio(vbox, "Volume Geral", AudioManager.volume_master, func(val):
		AudioManager.definir_volume_master(val)
	)

	# 2. Slider Volume Música
	criar_slider_audio(vbox, "Música", AudioManager.volume_musica, func(val):
		AudioManager.definir_volume_musica(val)
	)

	# 3. Slider Volume SFX
	criar_slider_audio(vbox, "Efeitos Sonoros (SFX)", AudioManager.volume_sfx, func(val):
		AudioManager.definir_volume_sfx(val)
		tocar_preview_som()
	)

	# 4. CheckButton Tela Cheia
	var check_tela_cheia = CheckButton.new()
	check_tela_cheia.text = "Tela Cheia"
	check_tela_cheia.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN)
	check_tela_cheia.toggled.connect(func(toggled):
		if toggled:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	vbox.add_child(check_tela_cheia)

	# Separador visual
	var spacer = Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	# 5. Botão Voltar
	var btn_voltar = Button.new()
	btn_voltar.text = "Voltar"
	btn_voltar.custom_minimum_size = Vector2(160, 36)
	btn_voltar.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_voltar.pressed.connect(fechar)
	vbox.add_child(btn_voltar)


func criar_slider_audio(pai: Node, rotulo: String, valor_inicial: float, callback: Callable) -> void:
	var container = VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)
	pai.add_child(container)

	var hbox = HBoxContainer.new()
	container.add_child(hbox)

	var lbl_nome = Label.new()
	lbl_nome.text = rotulo
	lbl_nome.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl_nome)

	var lbl_valor = Label.new()
	lbl_valor.text = str(int(round(valor_inicial * 100.0))) + "%"
	hbox.add_child(lbl_valor)

	var slider = HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 100.0
	slider.step = 1.0
	slider.value = valor_inicial * 100.0
	container.add_child(slider)

	slider.value_changed.connect(func(novo_val):
		lbl_valor.text = str(int(novo_val)) + "%"
		callback.call(novo_val / 100.0)
	)


func tocar_preview_som() -> void:
	if som_cooldown <= 0.0:
		som_cooldown = 0.12
		AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)


func fechar() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	queue_free()
