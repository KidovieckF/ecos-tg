extends Area2D

var vitoria_scene = preload("res://Cenas/Mundo/hud_vitoria.tscn")

func _on_body_entered(body: Node2D) -> void:

	RunData.guardar_player(get_tree().get_first_node_in_group("Players"))
	RunData.avancar_andar()
	if RunData.andar > 2:
		var vitoria_hud = vitoria_scene.instantiate()
		add_child(vitoria_hud)
	else:
		get_tree().change_scene_to_file("res://Cenas/Mundo/LobbyPrincipal.tscn")
	
	
