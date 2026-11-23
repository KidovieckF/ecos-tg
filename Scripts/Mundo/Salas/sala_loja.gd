extends Node2D

var player_dentro = false
var sensor_ja_ativado = false
var portas_da_sala = []
var aberto = false

var ui_cena = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")

var fala_primeira_vez = preload("res://Recursos/Npcs/Dialogos/Sasha_Run/Sasha_0_Run.tres")

var falas_loop = [
	preload("res://Recursos/Npcs/Dialogos/Sasha_Run/Sasha_1_Run.tres"),
	preload("res://Recursos/Npcs/Dialogos/Sasha_Run/Sasha_2_Run.tres"),
	preload("res://Recursos/Npcs/Dialogos/Sasha_Run/Sasha_3_Run.tres")
]

const ID_SAVE_SASHA_RUN = "sasha_run_conhecida"

func _ready() -> void:
	if has_node("StaticBody2D/Sasha"):
		$StaticBody2D/Sasha.play("default")


func _process(delta: float) -> void:
	var cbox = get_tree().get_first_node_in_group("Cbox")
	if cbox and cbox.visible:
		return

	if Input.is_action_just_pressed("Interagir") and player_dentro and not aberto:
		abrir_loja_com_dialogo()


func abrir_loja_com_dialogo() -> void:
	var fala_escolhida : FalaRecurso
	
	if not SaveManager.eh_quest_concluida(ID_SAVE_SASHA_RUN):
		SaveManager.concluir_quest(ID_SAVE_SASHA_RUN)
		fala_escolhida = fala_primeira_vez
	else:
		fala_escolhida = falas_loop.pick_random()
		
	if fala_escolhida == null:
		return
		
	var ui_Cb = ui_cena.instantiate()
	add_child(ui_Cb)
	ui_Cb.pegar_dialogo([fala_escolhida])
	ui_Cb.mostrar_dialogo()
	
	ui_Cb.tree_exited.connect(func():
		await get_tree().create_timer(0.35, false).timeout
		aberto = false
	)
	aberto = true


func inicar_sala(body):
	if sensor_ja_ativado == false:
		if body.is_in_group("Players"):
			sensor_ja_ativado = true
			# Abre todas as portas da loja imediatamente
			for p in portas_da_sala:
				if is_instance_valid(p):
					p.abrir_porta()


func _on_static_body_2d_body_entered(body: Node2D) -> void:
	player_dentro = true


func _on_static_body_2d_body_exited(body: Node2D) -> void:
	player_dentro = false


func ajustar_parede(norte, sul, leste, oeste):
	if norte == true and has_node("ParedeNorte"):
		$ParedeNorte.clear()
	if sul == true and has_node("ParedeSul"):
		$ParedeSul.clear()
	if leste == true and has_node("ParedeLeste"):
		$ParedeLeste.clear()
	if oeste == true and has_node("ParedeOeste"):
		$ParedeOeste.clear()


func _on_area_2d_body_entered(body: Node2D) -> void:
	inicar_sala(body)
