extends Node2D

@onready var player = $Player
@onready var inimigo = $InimigoBase
@onready var hud = $HUD

# Referência para a cena instanciada "Caixa_de_dialogo"
@onready var canvas_dialogo = $CanvasLayer
# O caminho exato para chegar no Label de fora da Cena embalada
@onready var meu_label = $CanvasLayer/GridContainer/MarginContainer/HBoxContainer/Panel/MarginContainer/VBoxContainer/Label if canvas_dialogo else null

enum Fase { ENTRANDO, INIMIGO_CHEGANDO, TUTORIAL, COMBATE }
var fase_atual = Fase.ENTRANDO
var linha_atual = 0
var tween_texto : Tween

var dialogos_tutorial = [
	"INIMIGO: Ora, ora... Uma forasteira no meu território.",
	"INIMIGO: Preste bem atenção se quiser sobreviver!",
	"INIMIGO: Use as setas (W, A, S, D) para se mover.",
	"INIMIGO: Mire com o Mouse e atire com o Botão Esquerdo.",
	"INIMIGO: Lá em cima na esquerda está sua Vida e sua Barra de XP.",
	"INIMIGO: Chega de conversa. Mostre o que sabe fazer! Prepare-se!"
]

func _ready():
	# 1. Desliga tudo para a cutscene
	if hud: hud.visible = false
	if player: player.set_physics_process(false)
	
	
	# Trava a câmera no centro da sala do tutorial e desliga ela de seguir o player no escuro
	if player:
		for child in player.get_children():
			if child is Camera2D:
				child.top_level = true
				child.set_physics_process(false)
				child.global_position = Vector2(569.5, 320.5) # Exato meio da tela baseado no seu room_size
	
	if inimigo: 
		inimigo.set_physics_process(false)
		inimigo.global_position = Vector2(1200, 350) # Esconde ele na direita da tela
	
	# 2. Faz o Player entrar na tela
	if player:
		# Posição inicial (escondida na esquerda)
		player.global_position = Vector2(-100, 350) 
		var sprite_player = player.get_node("Sprite2D")
		sprite_player.play("AndandoLado")
		sprite_player.flip_h = false # Olha pra direita
		
		# Caminha até o meio da tela
		var tween = create_tween()
		var pos_centro = Vector2(500, 350)
		tween.tween_property(player, "global_position", pos_centro, 2.0)
		
		tween.tween_callback(func():
			sprite_player.play("IdleLado") # Para e fica Idle pra direita
			# Pequeno atraso pra respirar e o inimigo entra
			var timer = get_tree().create_timer(0.5)
			timer.timeout.connect(chamar_inimigo)
		)

func chamar_inimigo():
	fase_atual = Fase.INIMIGO_CHEGANDO
	if not inimigo: return
	
	var tween = create_tween()
	var pos_inimigo_alvo = Vector2(800, 350) # Fica a uma distância do player
	tween.tween_property(inimigo, "global_position", pos_inimigo_alvo, 2.0)
	
	tween.tween_callback(func():
		# 3. Pulinho de susto do Player
		var tween_pulo = create_tween()
		var p_pos = player.global_position
		tween_pulo.tween_property(player, "global_position:y", p_pos.y - 40, 0.15)
		tween_pulo.tween_property(player, "global_position:y", p_pos.y, 0.15)
		
		tween_pulo.tween_callback(func():
			iniciar_tutorial()
		)
	)

func iniciar_tutorial():
	fase_atual = Fase.TUTORIAL
	if hud: hud.visible = true
	
	if canvas_dialogo:
		canvas_dialogo.visible = true
	
	if not meu_label:
		print("ERRO: O %Label não foi encontrado na Cena! O diálogo não vai aparecer.")
		return
		
	linha_atual = 0
	exibir_texto(dialogos_tutorial[linha_atual])

func exibir_texto(texto: String):
	meu_label.text = texto
	meu_label.visible_characters = 0
	
	if tween_texto and tween_texto.is_valid():
		tween_texto.kill()
		
	tween_texto = create_tween()
	var total = texto.length()
	tween_texto.tween_property(meu_label, "visible_characters", total, total * 0.05)

func _input(event):
	if fase_atual != Fase.TUTORIAL or not meu_label: return
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("Atirar"):
		if meu_label.visible_characters < meu_label.text.length():
			if tween_texto and tween_texto.is_valid(): tween_texto.kill()
			meu_label.visible_characters = meu_label.text.length()
		else:
			linha_atual += 1
			if linha_atual < dialogos_tutorial.size():
				exibir_texto(dialogos_tutorial[linha_atual])
			else:
				iniciar_combate()

func iniciar_combate():
	player.trocar_camera()
	fase_atual = Fase.COMBATE
	if meu_label:
		meu_label.text = ""
		
	if canvas_dialogo:
		canvas_dialogo.visible = false
	
	# 4. Solta a coleira, o combate começa!
	if player: 
		player.set_physics_process(true)
		for child in player.get_children():
			if child is Camera2D:
				child.top_level = false
				child.set_physics_process(true)
	
	if inimigo: inimigo.set_physics_process(true)
	print("COMBATE INICIADO!")
	

func _on_trigger_geral_body_entered(body: Node2D) -> void:
	# Só ativa se o combate já começou (o player tá solto) e se quem bateu foi o Player
	if fase_atual == Fase.COMBATE and body.name == "Player":
		
		# 1. Trava o jogador
		body.set_physics_process(false)
		
		# 2. Vira o sprite pra direita e troca pra animação de andar
		var sprite_player = body.get_node("Sprite2D")
		sprite_player.flip_h = false
		sprite_player.play("AndandoLado")
		
		# 3. Empurra ele uns 50 pixels de volta para a direita
		var tween = create_tween()
		var recuo_pos = body.global_position.x + 50
		tween.tween_property(body, "global_position:x", recuo_pos, 0.5)
		
		# 4. Mostra o texto quando terminar o empurrão
		tween.tween_callback(func():
			sprite_player.play("IdleLado") # Para de andar
			
			if canvas_dialogo:
				canvas_dialogo.visible = true
			
			fase_atual = Fase.TUTORIAL # Reusa a fase TUTORIAL para aproveitar o esquema de apertar espaço pra passar
			
			# Modifica nossa lista de diálogos para ter só essa fala de aviso
			dialogos_tutorial = ["ALICE: Acho melhor eu não voltar por aí..."]
			linha_atual = 0
			exibir_texto(dialogos_tutorial[linha_atual])
		)
