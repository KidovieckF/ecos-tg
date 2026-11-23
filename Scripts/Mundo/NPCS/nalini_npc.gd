extends Area2D

var ui_cena = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")
var player_perto = false
var aberto = false

@export_group("Diálogos")
@export var dialogo_primeira_vez : Array[FalaRecurso] 
@export var dialogo_loop : Array[FalaRecurso]        

@export_group("Visual")
@export var textura : Texture2D

const ID_SAVE_NALINI = "nalini_conhecida"

func _ready() -> void:
	$Sprite2D.play("default")

func _physics_process(delta: float) -> void:
	var cbox = get_tree().get_first_node_in_group("Cbox")
	if cbox and cbox.visible:
		return
		
	if Input.is_action_just_pressed("Interagir") and player_perto and not aberto:
		abrir_conversa()

func abrir_conversa() -> void:
	var falas_para_mostrar = selecionar_dialogo_atual()
	if falas_para_mostrar.is_empty():
		return
		
	var ui_Cb = ui_cena.instantiate()
	add_child(ui_Cb)
	ui_Cb.pegar_dialogo(falas_para_mostrar)
	ui_Cb.mostrar_dialogo()
	
	ui_Cb.tree_exited.connect(func():
		await get_tree().create_timer(0.35, false).timeout
		aberto = false
	)
	aberto = true

func selecionar_dialogo_atual() -> Array[FalaRecurso]:
	if SaveManager.eh_quest_concluida(ID_SAVE_NALINI):
		return dialogo_loop
		
	SaveManager.concluir_quest(ID_SAVE_NALINI)
	return dialogo_primeira_vez

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"): player_perto = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"): player_perto = false
