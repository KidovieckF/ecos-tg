extends Node2D
const VELOCIDADE := 300.0
const TAMANHO_FUNDO := 1152.0
var andando = true
var tempo_passado := 0.0
var dialogos = [
	"Olá, Alice! Bem-vinda à floresta mágica...",
	"Tome muito cuidado com os morcegos nas sombras.",
	"Siga a trilha de luz para encontrar o caminho!"
]
var linha_atual = 0 
var cena_atual = 1 # Controle de qual ato da cutscene estamos

@onready var meu_label = %Label # Troque pelo caminho do seu Label

func _process(delta):
	if andando:
		tempo_passado += delta
		if tempo_passado >= 3.0 and cena_atual == 1:
			cena_atual = 2 # Garante que não vai travar mais no _process
			andando = false
			meu_label.text = dialogos[linha_atual]
			meu_label.visible_characters = 0
			animar_texto()

		$Fundo.position.x -= VELOCIDADE * delta
		$Fundo2.position.x -= VELOCIDADE * delta
		$Fundo3.position.x -= VELOCIDADE * delta

	if $Fundo.position.x <= -TAMANHO_FUNDO:
		$Fundo.position.x = $Fundo3.position.x + TAMANHO_FUNDO

	if $Fundo2.position.x <= -TAMANHO_FUNDO:
		$Fundo2.position.x = $Fundo3.position.x + TAMANHO_FUNDO

	if $Fundo3.position.x <= -TAMANHO_FUNDO:
		$Fundo3.position.x = $Fundo2.position.x + TAMANHO_FUNDO
		
func _ready() -> void:
	$AnimationPlayer.play("Alice_Andando")
	
var tween_texto : Tween

func animar_texto():
	# Garante que não tenha dois tweens brigando
	if tween_texto and tween_texto.is_valid():
		tween_texto.kill()
		
	tween_texto = create_tween()
	var total_de_letras = meu_label.text.length()
	# Usa o tempo baseado na quantidade de letras pra não ficar nem muito rápido nem devagar
	tween_texto.tween_property(meu_label, "visible_characters", total_de_letras, total_de_letras * 0.05)

func _input(event: InputEvent) -> void:
	# Só funciona se o jogo não estiver mais andando
	if andando: return 
	
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("Atirar"):
		# Se ainda tá escrevendo...
		if meu_label.visible_characters < meu_label.text.length():
			if tween_texto and tween_texto.is_valid():
				tween_texto.kill()
			meu_label.visible_characters = meu_label.text.length() # Completa instantâneo
		else:
			# Se já acabou de escrever, passa pra próxima linha
			linha_atual += 1
			if linha_atual < dialogos.size():
				meu_label.text = dialogos[linha_atual]
				meu_label.visible_characters = 0
				animar_texto()
			else:
				if cena_atual == 2:
					cena_atual = 3
					andando = true
					$AnimationPlayer.play("Alice_Andando")
					var relogio = get_tree().create_timer(2.0)
					relogio.timeout.connect(func():
						sair_da_tela()
					)
		
func sair_da_tela():
	$AnimationPlayer.play("Alice_Andando")
	
	var alice = $Sprite2D 
	
	var tween = create_tween()
	
	var alvo_x = alice.global_position.x + 800
	tween.tween_property(alice, "global_position:x", alvo_x, 2.5)
	
	tween.tween_callback(func():
		get_tree().change_scene_to_file("res://Cenas/Cutscenes/cs_02_tutorial.tscn")
	)
