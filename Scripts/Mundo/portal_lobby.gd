extends Area2D


func _on_body_entered(body: Node2D) -> void:

	RunData.guardar_player(get_tree().get_first_node_in_group("Players"))
	RunData.avancar_andar()
	get_tree().change_scene_to_file("res://Cenas/Mundo/LobbyPrincipal.tscn")
	
	
