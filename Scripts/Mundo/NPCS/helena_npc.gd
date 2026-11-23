extends Area2D

var ui_cena = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")
var player_perto: bool = false
var aberto: bool = false

@export_group("Diálogos")
# No Inspector do Lobby: Helena_Menu_1.tres (que encadeia 1.1 -> 1.2 -> 1.3)
@export var dialogo_intro : Array[FalaRecurso] = []

# No Inspector do Lobby: Helena_Menu_2L.tres e Helena_Menu_3L.tres
@export var menus_loop : Array[FalaRecurso] = []

const ID_SAVE_HELENA_INTRO = "helena_intro_concluida"


func _ready() -> void:
	if has_node("Sprite2D"):
		$Sprite2D.play("default")


func _physics_process(delta: float) -> void:
	var cbox = get_tree().get_first_node_in_group("Cbox")
	if cbox and cbox.visible:
		return
		
	if Input.is_action_just_pressed("Interagir") and player_perto and not aberto:
		abrir_conversa()


func abrir_conversa() -> void:
	var falas_para_mostrar: Array[FalaRecurso] = []
	
	# 1. Primeira vez falando com ela: reproduz a introdução completa
	if not SaveManager.eh_quest_concluida(ID_SAVE_HELENA_INTRO):
		SaveManager.concluir_quest(ID_SAVE_HELENA_INTRO)
		falas_para_mostrar = dialogo_intro
	else:
		# 2. Já conversou antes: sorteia aleatoriamente um dos menus de repetição
		if not menus_loop.is_empty():
			falas_para_mostrar = [menus_loop.pick_random()]
			
	if falas_para_mostrar.is_empty():
		return
		
	var ui_Cb = ui_cena.instantiate()
	add_child(ui_Cb)
	ui_Cb.pegar_dialogo(falas_para_mostrar)
	ui_Cb.mostrar_dialogo()
	
	# Conecta para escutar o gatilho "liberar_treino" vindo dos .tres
	ui_Cb.acao_disparada.connect(_ao_disparar_acao)
	
	ui_Cb.tree_exited.connect(func():
		await get_tree().create_timer(0.35, false).timeout
		aberto = false
	)
	aberto = true


func _ao_disparar_acao(nome_acao: String) -> void:
	if nome_acao == "liberar_treino":
		RunData.treino_liberado = true
		get_tree().call_group("Dummies", "liberar_para_treino")
		print("🎯 Helena autorizou o treinamento nos Dummies!")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_perto = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		player_perto = false
