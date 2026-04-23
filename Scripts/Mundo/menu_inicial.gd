extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_iniciar_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://Cenas/Mundo/LobbyPrincipal.tscn")


func _on_configs_btn_pressed() -> void:
	pass # Replace with function body.


func _on_sair_btn_pressed() -> void:
	get_tree().quit()
