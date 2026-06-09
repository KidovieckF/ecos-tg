extends Area2D


var ui_cena = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")
var arma_cena = preload("res://Cenas/Mundo/Lobby/Selecao_Arma.tscn")
var player_perto = false
var aberto = false
signal dar_falas
@export var dialogo : Array[FalaRecurso]

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and player_perto and not aberto:
		var ui_Cb = ui_cena.instantiate()
		add_child(ui_Cb)
		ui_Cb.pegar_dialogo(dialogo)
		ui_Cb.mostrar_dialogo()
		ui_Cb.tree_exited.connect(dialogo_terminou)
		aberto = true
		var hud = get_tree().get_first_node_in_group("Cbox")
	if Input.is_action_just_pressed("Mudar") and player_perto:
		var ui_Arma = arma_cena.instantiate()
		add_child(ui_Arma)

	
func dialogo_terminou():
	aberto = false

func _on_body_entered(body: Node2D) -> void:
	player_perto = true


func _on_body_exited(body: Node2D) -> void:
	player_perto = false
