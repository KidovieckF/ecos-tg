extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_menu_pressed() -> void:
	get_tree().paused = false
	RunData.resetar_run()
	get_tree().change_scene_to_file("res://Cenas/Mundo/Menu_inicial.tscn")




func _on_recomeçar_pressed() -> void:
	get_tree().paused = false
	RunData.resetar_run()
	get_tree().change_scene_to_file("res://Cenas/Mundo/LobbyPrincipal.tscn")
