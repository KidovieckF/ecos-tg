extends Node2D

# Marque como true no Inspector ou aqui para testar a cutscene sempre que der Play!
@export var forcar_primeira_vez : bool = true

var conv_box = preload("res://Cenas/Mundo/NPCS/Cb_UI.tscn")
var textura_miro = preload("res://sprites/characters/Miro.png")

# Referências aos dois nós da cena
@onready var miro_intro = get_node_or_null("Miro")       # Sprite2D temporário da caminhada
@onready var miro_npc_loja = get_node_or_null("Miro2")   # NPC permanente na loja

func _ready() -> void:
	AudioManager.tocar_musica(AudioManager.BGM_LOBBY)
	var player = get_tree().get_first_node_in_group("Players")
	if not player: return
	
	player.set_physics_process(false)
	var posicao_final = player.global_position
	var posicao_inicio = posicao_final + Vector2(0, 400)
	player.global_position = posicao_inicio
	player.get_node("Sprite2D").play("AndandoCosta")
	
	# Verifica o save OU se você marcou para forçar o teste
	var primeira_vez = SaveManager.eh_primeira_vez_lobby() or forcar_primeira_vez
	
	if primeira_vez:
		# 1. Desativa e esconde a Miro da loja para não interagir durante a cutscene
		if miro_npc_loja:
			miro_npc_loja.visible = false
			miro_npc_loja.process_mode = Node.PROCESS_MODE_DISABLED
			
		if miro_intro:
			miro_intro.global_position = posicao_inicio + Vector2(50, 0)
			miro_intro.visible = true
			miro_intro.modulate.a = 1.0
			
		var tween = create_tween().set_parallel(true)
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(player, "global_position", posicao_final, 2.5)
		if miro_intro:
			tween.tween_property(miro_intro, "global_position", posicao_final + Vector2(50, 0), 2.5)
			
		tween.finished.connect(func():
			player.get_node("Sprite2D").play("IdleCostas")
			iniciar_dialogo_primeira_vez()
		)
	else:
		if miro_intro:
			miro_intro.queue_free()
			
		if miro_npc_loja:
			miro_npc_loja.visible = true
			miro_npc_loja.process_mode = Node.PROCESS_MODE_INHERIT
			
		var tween = create_tween()
		tween.set_trans(Tween.TRANS_LINEAR)
		tween.tween_property(player, "global_position", posicao_final, 2.5)
		tween.tween_callback(func():
			player.get_node("Sprite2D").play("IdleCostas")
			player.set_physics_process(true)
		)

func iniciar_dialogo_primeira_vez() -> void:
	var ui_dialogo = conv_box.instantiate()
	add_child(ui_dialogo)
	
	var falas = criar_falas_primeira_visita()
	ui_dialogo.pegar_dialogo(falas)
	ui_dialogo.mostrar_dialogo()
	
	ui_dialogo.tree_exited.connect(func():
		SaveManager.marcar_lobby_como_visitado()
		
		var player = get_tree().get_first_node_in_group("Players")
		if player:
			player.set_physics_process(true)
		
		if is_instance_valid(miro_intro):
			var destino = miro_intro.global_position + Vector2(0, -350) # Sobe 350 pixels
			var tween_saida = create_tween()
			tween_saida.set_trans(Tween.TRANS_LINEAR)
			
			tween_saida.tween_property(miro_intro, "global_position", destino, 2.0)
			tween_saida.parallel().tween_property(miro_intro, "modulate:a", 0.0, 0.6).set_delay(1.4)
			
			tween_saida.tween_callback(func():
				miro_intro.queue_free()
				if is_instance_valid(miro_npc_loja):
					miro_npc_loja.visible = true
					miro_npc_loja.process_mode = Node.PROCESS_MODE_INHERIT
			)
		else:
			if is_instance_valid(miro_npc_loja):
				miro_npc_loja.visible = true
				miro_npc_loja.process_mode = Node.PROCESS_MODE_INHERIT
	)

func criar_falas_primeira_visita() -> Array[FalaRecurso]:
	var lista : Array[FalaRecurso] = []
	var textos = [
		"Chegamo, fia! Seja muito bem-vinda ao nosso cantinho seguro. Esse aqui é o coração do vilarejo!",
		"Óia ao redor... Ali adiante ocê vai topar com a Nalini e a Helena. Elas tão sempre por aí e podem te ensinar um bocado.",
		"Eu mesma tomo conta da Loja de Mascotes aqui da cidade! Cuido duns bichinhos danados de leais que te dão uma baita força nas batalhas.",
		"Dá uma boa perambulada por aí, troca dois dedos de prosa com o povo e se ajeita. Quando quiser voltar pra floresta, é só entrar naquele portal!"
	]
	
	for t in textos:
		var f = FalaRecurso.new()
		f.set("nome_falante", "Miro")
		f.set("foto", textura_miro)
		f.falas = t
		lista.append(f)
		
	return lista


func _on_area_treino_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		$HUD.visible = true

func _on_area_treino_body_exited(body: Node2D) -> void:
	if body.is_in_group("Players"):
		$HUD.visible = false
