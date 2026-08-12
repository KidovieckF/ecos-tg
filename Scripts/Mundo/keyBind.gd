extends Control

var esperando_tecla = false
var acao_atual = "" # Guarda se é "Atirar", "ui_left", etc
var botao_atual = null # Guarda qual botão na tela precisa ter o texto atualizado

func _ready() -> void:
	set_process_unhandled_input(false)
	var atirar = InputMap.action_get_events("Atirar")[0].as_text()
	
	%keyBindBtn.text = "Atirar : " + atirar 
	%keyBindBtn2.text = "Esquerda : " + InputMap.action_get_events("ui_left")[0].as_text() 
	%keyBindBtn3.text = "Direita : " + InputMap.action_get_events("ui_right")[0].as_text()
	%keyBindBtn4.text = "Cima : " + InputMap.action_get_events("ui_up")[0].as_text()
	%keyBindBtn5.text = "Baixo : " + InputMap.action_get_events("ui_down")[0].as_text()
	
func _unhandled_input(event):
	if esperando_tecla == true:
		if (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			# Agora usamos a variável dinâmica em vez da palavra fixa!
			InputMap.action_erase_events(acao_atual)
			InputMap.action_add_event(acao_atual, event)
			
			# Atualizamos o texto com base no botão certo!
			if acao_atual == "Atirar":
				botao_atual.text = "Atirar : " + event.as_text()
			elif acao_atual == "ui_left":
				botao_atual.text = "Esquerda : " + event.as_text()
			elif acao_atual == "ui_right":
				botao_atual.text = "Direita : " + event.as_text()
			elif acao_atual == "ui_up":
				botao_atual.text = "Cima : " + event.as_text()
			elif acao_atual == "ui_down":
				botao_atual.text = "Baixo : " + event.as_text()
				
			get_viewport().set_input_as_handled()
			esperando_tecla = false
			set_process_unhandled_input(false)

# --- BOTÕES ---

func _on_key_bind_btn_pressed() -> void:
	esperando_tecla = true
	acao_atual = "Atirar"
	botao_atual = %keyBindBtn
	set_process_unhandled_input(true)
	InputMap.action_erase_events(acao_atual)
	botao_atual.text = "Atirar : (Pressione um botão)"

func _on_key_bind_btn_2_pressed() -> void:
	esperando_tecla = true
	acao_atual = "ui_left"
	botao_atual = %keyBindBtn2
	set_process_unhandled_input(true)
	InputMap.action_erase_events(acao_atual)
	botao_atual.text = "Esquerda : (Pressione um botão)"

func _on_key_bind_btn_3_pressed() -> void:
	esperando_tecla = true
	acao_atual = "ui_right"
	botao_atual = %keyBindBtn3
	set_process_unhandled_input(true)
	InputMap.action_erase_events(acao_atual)
	botao_atual.text = "Direita : (Pressione um botão)"

func _on_key_bind_btn_4_pressed() -> void:
	esperando_tecla = true
	acao_atual = "ui_up"
	botao_atual = %keyBindBtn4
	set_process_unhandled_input(true)
	InputMap.action_erase_events(acao_atual)
	botao_atual.text = "Cima : (Pressione um botão)"

func _on_key_bind_btn_5_pressed() -> void:
	esperando_tecla = true
	acao_atual = "ui_down"
	botao_atual = %keyBindBtn5
	set_process_unhandled_input(true)
	InputMap.action_erase_events(acao_atual)
	botao_atual.text = "Baixo : (Pressione um botão)"

func _on_voltar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/configs.tscn")
 
