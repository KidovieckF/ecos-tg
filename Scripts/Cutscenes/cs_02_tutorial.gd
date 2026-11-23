extends Node2D

@onready var player = $Player
@onready var inimigo = $InimigoBase
@onready var hud = $HUD
@onready var miro = $Miro

@onready var canvas_dialogo = $CanvasLayer
@onready var meu_label = $CanvasLayer/GridContainer/MarginContainer/HBoxContainer/Panel/MarginContainer/VBoxContainer/Label if canvas_dialogo else null
@onready var label_nome = $CanvasLayer/GridContainer/MarginContainer/HBoxContainer/Panel/TextureRect2/Label if canvas_dialogo else null
@onready var portrait_dialogo = $CanvasLayer/GridContainer/MarginContainer/HBoxContainer/TextureRect if canvas_dialogo else null

enum Fase { ENTRANDO, INIMIGO_CHEGANDO, TUTORIAL_PRE_COMBATE, COMBATE, POS_COMBATE, CONCLUIDO }
var fase_atual = Fase.ENTRANDO
var linha_atual = 0
var tween_texto : Tween

var timer_taunt: float = 0.0

var dialogos_tutorial = [
	"Ei, cuidado aí na frente! Essa coisa escapou e tá indo babando pra cima de você!",
	"Não fica aí parada com cara de paisagem! Me ajuda aqui antes que esse bicho quebre tudo!",
	"Usa [W, A, S, D] pra se mexer rápido. A não ser que você queira levar uma pancada de graça.",
	"Aponta o mouse e clica no Botão Esquerdo pra jogar essas tuas magias bem na fuça dele!",
	"Fica de olho na sua Vida e na barra de XP ali em cima. Não vai me morrer de bobeira, hein!",
	"Chega de papo, ele tá vindo! Mostra pra que veio!"
]

var dialogos_pos_combate = [
	"Olha só... até que você não é um desastre completo. Mandou bem de verdade!",
	"Nem me apresent- Ah é você Alice. Sou eu a Miro! Quanto Tempo.",
	"Você ainda tem jeito pra coisa, garota. Entra naquele portal ali na frente que dá direto na vila. Não enrola, te vejo lá!"
]

var taunts_combate = [
	"Não fica parada, tá esperando um convite?!",
	"Mire direito, tá atirando no vento!",
	"Desvia disso! Acorda!",
	"Boa! Agora não deixa ele respirar!",
	"Até que você tem mira, continua!",
	"Sai da reta dele, não é de ferro não!"
]

func _ready() -> void:
	if hud: hud.visible = false
	if player: player.set_physics_process(false)
	
	if player:
		for child in player.get_children():
			if child is Camera2D:
				child.top_level = true
				child.set_physics_process(false)
				child.global_position = Vector2(569.5, 320.5)
	
	if inimigo: 
		inimigo.set_physics_process(false)
		inimigo.global_position = Vector2(1200, 350)
		
	if miro:
		miro.global_position = Vector2(1420, 332)
	
	if player:
		player.global_position = Vector2(-100, 350) 
		var sprite_player = player.get_node("Sprite2D")
		sprite_player.play("AndandoLado")
		sprite_player.flip_h = false
		
		var tween = create_tween()
		var pos_centro = Vector2(500, 350)
		tween.tween_property(player, "global_position", pos_centro, 2.0)
		
		tween.tween_callback(func():
			sprite_player.play("IdleLado")
			var timer = get_tree().create_timer(0.5)
			timer.timeout.connect(chamar_inimigo_e_miro)
		)

func _process(delta: float) -> void:
	if fase_atual == Fase.COMBATE and inimigo and is_instance_valid(inimigo):
		timer_taunt += delta
		if timer_taunt >= 4.5:
			timer_taunt = 0.0
			_soltar_taunt()

func _soltar_taunt() -> void:
	if taunts_combate.is_empty() or not canvas_dialogo or not meu_label:
		return
		
	var fala = taunts_combate.pick_random()
	
	if label_nome:
		label_nome.text = "Miro"
		
	meu_label.text = fala
	meu_label.visible_characters = -1
	canvas_dialogo.visible = true
	
	var t = create_tween()
	t.tween_interval(2.2)
	t.tween_callback(func():
		if fase_atual == Fase.COMBATE and canvas_dialogo:
			canvas_dialogo.visible = false
	)

func chamar_inimigo_e_miro() -> void:
	fase_atual = Fase.INIMIGO_CHEGANDO
	if not inimigo: return
	
	var tween_inimigo = create_tween()
	var pos_inimigo_alvo = Vector2(800, 350)
	tween_inimigo.tween_property(inimigo, "global_position", pos_inimigo_alvo, 1.8)
	
	if miro:
		var tween_miro = create_tween()
		var pos_miro_alvo = Vector2(980, 332)
		tween_miro.tween_property(miro, "global_position", pos_miro_alvo, 2.2)
	
	tween_inimigo.tween_callback(func():
		var tween_pulo = create_tween()
		var p_pos = player.global_position
		tween_pulo.tween_property(player, "global_position:y", p_pos.y - 40, 0.15)
		tween_pulo.tween_property(player, "global_position:y", p_pos.y, 0.15)
		
		tween_pulo.tween_callback(func():
			iniciar_tutorial()
		)
	)

func iniciar_tutorial() -> void:
	fase_atual = Fase.TUTORIAL_PRE_COMBATE
	if hud: hud.visible = true
	
	if label_nome:
		label_nome.text = "?????"
		
	if canvas_dialogo:
		canvas_dialogo.visible = true
	
	if not meu_label:
		print("ERRO: O Label de diálogo não foi encontrado!")
		return
		
	linha_atual = 0
	exibir_texto(dialogos_tutorial[linha_atual])

func exibir_texto(texto: String) -> void:
	meu_label.text = texto
	meu_label.visible_characters = 0
	
	if tween_texto and tween_texto.is_valid():
		tween_texto.kill()
		
	tween_texto = create_tween()
	var total = texto.length()
	tween_texto.tween_property(meu_label, "visible_characters", total, total * 0.035)

func _input(event: InputEvent) -> void:
	if not (fase_atual == Fase.TUTORIAL_PRE_COMBATE or fase_atual == Fase.POS_COMBATE):
		return
	if not meu_label:
		return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("Atirar"):
		if meu_label.visible_characters < meu_label.text.length():
			if tween_texto and tween_texto.is_valid():
				tween_texto.kill()
			meu_label.visible_characters = meu_label.text.length()
		else:
			# Avança a conversa
			linha_atual += 1
			
			if fase_atual == Fase.TUTORIAL_PRE_COMBATE:
				if linha_atual < dialogos_tutorial.size():
					exibir_texto(dialogos_tutorial[linha_atual])
				else:
					iniciar_combate()
					
			elif fase_atual == Fase.POS_COMBATE:
				if linha_atual < dialogos_pos_combate.size():
					if linha_atual == 1 and label_nome:
						label_nome.text = "Miro"
					exibir_texto(dialogos_pos_combate[linha_atual])
				else:
					concluir_cutscene()

func iniciar_combate() -> void:
	player.trocar_camera()
	fase_atual = Fase.COMBATE
	if meu_label:
		meu_label.text = ""
		
	if canvas_dialogo:
		canvas_dialogo.visible = false
	
	if player: 
		player.set_physics_process(true)
		for child in player.get_children():
			if child is Camera2D:
				child.top_level = false
				child.set_physics_process(true)
	
	if inimigo and is_instance_valid(inimigo):
		inimigo.set_physics_process(true)
		inimigo.morreu.connect(_on_inimigo_derrotado)
		
	print("COMBATE INICIADO!")

func _on_inimigo_derrotado() -> void:
	await get_tree().create_timer(0.6).timeout
	
	fase_atual = Fase.POS_COMBATE
	
	if player:
		player.set_physics_process(false)
		var sprite_player = player.get_node_or_null("Sprite2D")
		if sprite_player:
			sprite_player.play("IdleLado")
	
	if miro:
		var tween_miro = create_tween()
		var pos_aproximar = Vector2(700, 332)
		tween_miro.tween_property(miro, "global_position", pos_aproximar, 1.0)
		await tween_miro.finished
	
	if label_nome:
		label_nome.text = "?????"
		
	if canvas_dialogo:
		canvas_dialogo.visible = true
		
	linha_atual = 0
	exibir_texto(dialogos_pos_combate[linha_atual])

func concluir_cutscene() -> void:
	fase_atual = Fase.CONCLUIDO
	
	if canvas_dialogo:
		canvas_dialogo.visible = false
		
	if player:
		player.set_physics_process(true)
		
	print("TUTORIAL CONCLUÍDO! Portal liberado para o Lobby.")

func _on_trigger_geral_body_entered(body: Node2D) -> void:
	if fase_atual == Fase.COMBATE and body.name == "Player":
		body.set_physics_process(false)
		
		var sprite_player = body.get_node("Sprite2D")
		sprite_player.flip_h = false
		sprite_player.play("AndandoLado")
		
		var tween = create_tween()
		var recuo_pos = body.global_position.x + 50
		tween.tween_property(body, "global_position:x", recuo_pos, 0.5)
		
		tween.tween_callback(func():
			sprite_player.play("IdleLado")
			if canvas_dialogo:
				canvas_dialogo.visible = true
			if label_nome:
				label_nome.text = "Alice"
				
			dialogos_tutorial = ["ALICE: Acho melhor eu não voltar por aí..."]
			linha_atual = 0
			exibir_texto(dialogos_tutorial[linha_atual])
		)
