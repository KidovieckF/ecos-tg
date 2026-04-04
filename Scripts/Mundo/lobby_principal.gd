extends Node2D

var conv_box = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")



func interagir_npc():
	var Ui_npc = conv_box.instantiate()
	add_child(Ui_npc)
