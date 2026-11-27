extends CanvasLayer

signal acao_disparada(nome_acao: String)

@onready var texture_foto = $GridContainer/MarginContainer/HBoxContainer/TextureRect
@onready var label_nome = $GridContainer/MarginContainer/HBoxContainer/Panel/MarginContainer/VBoxContainer/Label
@onready var label_fala = %Label2

@onready var botoes_respostas: Array[Button] = [
	%resposta1,
	%resposta2,
	%resposta3,
	%resposta4,
	%resposta5
]

var aguardando_cena_fechar : bool = false
var lista_atual : Array[FalaRecurso] = []
var indice : int = 0
var aguardando_resposta : bool = false
var recurso_atual : FalaRecurso = null
var tween_texto : Tween

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("Players")
	if player:
		player.set_physics_process(false)
		
	if label_fala:
		label_fala.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label_fala.custom_minimum_size = Vector2(580, 0)

func _process(delta: float) -> void:
	if not aguardando_resposta and not aguardando_cena_fechar:
		if Input.is_action_just_pressed("Interagir"):
			if label_fala and label_fala.visible_characters < label_fala.text.length():
				if tween_texto and tween_texto.is_valid():
					tween_texto.kill()
				label_fala.visible_characters = label_fala.text.length()
			else:
				if recurso_atual and recurso_atual.get("cena_para_abrir") and recurso_atual.cena_para_abrir != null:
					abrir_cena_e_esperar(recurso_atual.cena_para_abrir)
					return
					
				if indice < lista_atual.size():
					mostrar_dialogo()
				elif recurso_atual and recurso_atual.get("voltar_para") and recurso_atual.voltar_para != "":
					var prox_rec = load(recurso_atual.voltar_para)
					if prox_rec is FalaRecurso:
						pegar_dialogo([prox_rec])
						mostrar_dialogo()
					else:
						fechar_dialogo()
				elif recurso_atual and recurso_atual.proximo_1.size() > 0:
					processar_escolha(recurso_atual.proximo_1)

				else:
					fechar_dialogo()


func abrir_cena_e_esperar(cena: PackedScene) -> void:
	aguardando_cena_fechar = true
	visible = false
	
	var proxima_fala = recurso_atual.proximo_1.duplicate() if (recurso_atual and recurso_atual.proximo_1.size() > 0) else []
	
	var instancia = cena.instantiate()
	get_tree().current_scene.add_child(instancia)
	
	instancia.tree_exited.connect(func():
		aguardando_cena_fechar = false
		visible = true # Reaparece a caixa de diálogo
		
		if proxima_fala.size() > 0:
			processar_escolha(proxima_fala)
		else:
			fechar_dialogo()
	)

func pegar_dialogo(lista) -> void:
	lista_atual.assign(lista)
	indice = 0

func mostrar_dialogo() -> void:
	if indice >= lista_atual.size():
		fechar_dialogo()
		return
		
	recurso_atual = lista_atual[indice]
	indice += 1
	if recurso_atual and recurso_atual.gatilho_acao != "":
		acao_disparada.emit(recurso_atual.gatilho_acao)
	
	# Nome e Foto
	if label_nome:
		if recurso_atual.nome_falante != "":
			label_nome.text = recurso_atual.nome_falante
			label_nome.visible = true
		else:
			label_nome.visible = false
			
	if texture_foto and recurso_atual.foto != null:
		texture_foto.texture = recurso_atual.foto
		texture_foto.visible = true
	
	# Texto animado
	animar_texto(recurso_atual.falas)
	
	# Botões de escolha
	var qtd_respostas = recurso_atual.respostas.size()
	if qtd_respostas == 0:
		esconder_todos_botoes()
		aguardando_resposta = false
	else:
		aguardando_resposta = true
		for i in range(botoes_respostas.size()):
			var btn = botoes_respostas[i]
			if btn != null:
				if i < qtd_respostas:
					btn.visible = true
					btn.text = recurso_atual.respostas[i]
				else:
					btn.visible = false

func esconder_todos_botoes() -> void:
	for btn in botoes_respostas:
		if btn != null:
			btn.visible = false

func animar_texto(texto: String) -> void:
	label_fala.text = texto
	label_fala.visible_characters = 0
	
	if tween_texto and tween_texto.is_valid():
		tween_texto.kill()
		
	tween_texto = create_tween()
	var total = texto.length()
	tween_texto.tween_property(label_fala, "visible_characters", total, total * 0.03)

func _on_resposta_1_pressed() -> void:
	processar_escolha(recurso_atual.proximo_1 if recurso_atual else [])

func _on_resposta_2_pressed() -> void:
	processar_escolha(recurso_atual.proximo_2 if recurso_atual else [])

func _on_resposta_3_pressed() -> void:
	processar_escolha(recurso_atual.get("proximo_3") if recurso_atual else [])

func _on_resposta_4_pressed() -> void:
	processar_escolha(recurso_atual.get("proximo_4") if recurso_atual else [])

func _on_resposta_5_pressed() -> void:
	processar_escolha(recurso_atual.get("proximo_5") if recurso_atual else [])

func processar_escolha(proxima_lista) -> void:
	if proxima_lista and proxima_lista.size() > 0:
		var nova_lista: Array[FalaRecurso] = []
		for item in proxima_lista:
			if item != null:
				nova_lista.append(item)
		if nova_lista.size() > 0:
			var fala_escolhida = nova_lista.pick_random()
			pegar_dialogo([fala_escolhida])
			mostrar_dialogo()
			return
	fechar_dialogo()

func fechar_dialogo() -> void:
	var player = get_tree().get_first_node_in_group("Players")
	if player:
		player.set_physics_process(true)
		
	queue_free()
