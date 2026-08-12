extends Control


func _ready() -> void:
	pass 


func _process(delta: float) -> void:
	pass




func _on_modo_direcional_toggled(toggled_on: bool) -> void:
	if toggled_on:
		RunData.gamemode = "Direcional"
		%ModoMouse.set_pressed_no_signal(false) # Desliga em modo furtivo!
	

		


func _on_modo_mouse_toggled(toggled_on: bool) -> void:
	if toggled_on:
		RunData.gamemode = "Mouse"
		print(RunData.gamemode)
		%ModoDirecional.set_pressed_no_signal(false)


func _on_voltar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/configs.tscn")
