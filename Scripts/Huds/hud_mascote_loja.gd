extends CanvasLayer

@export var recurso_greg: MascoteRucurso = preload("res://Recursos/Mascotes/Greg.tres")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	atualizar_visual()

func atualizar_visual() -> void:
	if %Textura1 and recurso_greg.textura:
		%Textura1.texture = recurso_greg.textura
	if %Nome1:
		%Nome1.text = recurso_greg.nome
	if %Descricao1:
		%Descricao1.text = recurso_greg.descricao
	
	if %MoedasLabel:
		%MoedasLabel.text = "Moedas: %d" % RunData.moeda_run

	if RunData.mascote_ativo == recurso_greg:
		%BtnComprar1.text = "Adquirido"
		%BtnComprar1.disabled = true
		%Preco.text = "Equipado"
		%Preco.modulate = Color(0.4, 1.0, 0.5)
	else:
		%BtnComprar1.text = "Comprar"
		%BtnComprar1.disabled = false
		%Preco.text = "%d Moedas" % recurso_greg.preco

func _on_btn_comprar_1_pressed() -> void:
	if RunData.moeda_run >= recurso_greg.preco:
		RunData.moeda_run -= recurso_greg.preco
		AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, 0.0, false)
		
		RunData.mascote_ativo = recurso_greg
		
		var p = get_tree().get_first_node_in_group("Players")
		if p:
			RunData.spawnar_mascote(p)
			
		atualizar_visual()
	else:
		var tween = create_tween().set_loops(3)
		tween.tween_property(%BtnComprar1, "modulate", Color(2.0, 0.4, 0.4), 0.1)
		tween.tween_property(%BtnComprar1, "modulate", Color.WHITE, 0.1)

func _on_btn_fechar_pressed() -> void:
	AudioManager.tocar_sfx(AudioManager.SFX_BOTAO, -2.0, false)
	queue_free()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
		_on_btn_fechar_pressed()
