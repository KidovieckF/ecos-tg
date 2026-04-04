extends Area2D


var ui_cena = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")
var player_perto = false

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and player_perto:
		var ui_Cb = ui_cena.instantiate()
		add_child(ui_Cb)

func _on_body_entered(body: Node2D) -> void:
	player_perto = true
