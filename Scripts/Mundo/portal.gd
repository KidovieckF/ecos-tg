extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		get_tree().change_scene_to_file("res://Cenas/Mundo/Mundo.tscn") # Muda para o jogo# Replace with function body.
		body.trocar_camera()
