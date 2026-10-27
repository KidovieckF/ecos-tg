extends Node2D

var conv_box = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")

func _ready() -> void:
	AudioManager.tocar_musica(AudioManager.BGM_LOBBY)
	var player = get_tree().get_first_node_in_group("Players")
	if not player: return
	
	player.set_physics_process(false)
	var posicao_final = player.global_position
	player.global_position = posicao_final + Vector2(0, 400)
	player.get_node("Sprite2D").play("AndandoCosta")
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(player, "global_position", posicao_final, 2.5)
	
	tween.tween_callback(func():
		player.get_node("Sprite2D").play("IdleCostas")
		player.set_physics_process(true)
	)

func interagir_npc():
	var Ui_npc = conv_box.instantiate()
	add_child(Ui_npc)
