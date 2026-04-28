extends Control
var esperando_tecla = false

func _ready() -> void:
	set_process_unhandled_input(false)
	var atirar = InputMap.action_get_events("Atirar")[0].as_text()
	%keyBindBtn.text = atirar
	%keyBindBtn2.text = "Esquerda : " + InputMap.action_get_events("ui_left")[0].as_text() 
	%keyBindBtn3.text = "Direita : " + InputMap.action_get_events("ui_right")[0].as_text()
	%keyBindBtn4.text = "Cima : " + InputMap.action_get_events("ui_up")[0].as_text()
	%keyBindBtn5.text = "Baixo : " + InputMap.action_get_events("ui_down")[0].as_text()
	
func _on_key_bind_btn_pressed() -> void:
	esperando_tecla = true
	set_process_unhandled_input(true)
	InputMap.action_erase_events("Atirar")
	%keyBindBtn.text = "Pressione um botão"
	
func _unhandled_input(event):
	if esperando_tecla == true:
		if event is InputEventKey or InputEventMouseButton:
			InputMap.action_erase_events("Atirar")
			InputMap.action_add_event("Atirar", event)
			%keyBindBtn.text = event.as_text()
			get_viewport().set_input_as_handled()
			esperando_tecla = false
			set_process_unhandled_input(false)


func _on_voltar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/configs.tscn")
