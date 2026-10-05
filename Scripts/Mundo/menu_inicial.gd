extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_iniciar_btn_pressed() -> void:
	# Desabilita o botão para não clicarem duas vezes durante a animação
	var btn = $GridContainer/Panel/GridContainer/MarginContainer/VBoxContainer/IniciarBtn
	if btn: btn.disabled = true
	
	# Cria a animação de deslizar para cima
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT) # Movimento suave
	
	# Move o menu inteiro para cima (menos a altura da tela) em 1.5 segundos
	var alvo_y = -get_viewport_rect().size.y
	tween.tween_property(self, "position:y", alvo_y, 1.5)
	
	# Assim que a animação terminar, carrega a próxima cena
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Cenas/Mundo/LobbyPrincipal.tscn")
	)
func _on_configs_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/configs.tscn")


func _on_sair_btn_pressed() -> void:
	get_tree().quit()
