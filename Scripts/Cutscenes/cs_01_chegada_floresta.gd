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

@onready var meu_label = %Label # Troque pelo caminho do seu Label

func _process(delta):
	if andando:
		tempo_passado += delta
		if tempo_passado >= 3.0:
			andando = false
			meu_label.text = "Olá, Alice! Bem-vinda à floresta mágica..."
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
	
	
	
	
	
func animar_texto():
	var tween = create_tween()
	var total_de_letras = meu_label.text.length()
	# Pede para o Tween animar a propriedade "visible_characters"
	# do nosso Label, indo de 0 até o total de letras, durando 3.0 segundos
	tween.tween_property(meu_label, "visible_characters", total_de_letras, 3.0)
	
