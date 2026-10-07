extends CharacterBody2D

@export var nome_boss : String = "Chefe Gigante"
@export var vida_base : float = 5000.0
@export var ataques : Array[String] = []
@export var tempo_entre_ataques : float = 3.0 

var vida_atual : float
var morto = false

@onready var timer_ataque = $TimerAtaque

@onready var barra_vida = $CanvasBoss/ProgressBar
@onready var anim = $AnimationPlayer

func _ready() -> void:
	vida_atual = vida_base * RunData.mult_dificuldade
	
	timer_ataque.wait_time = tempo_entre_ataques
	timer_ataque.start()
	anim.play("Idle")

func _on_timer_ataque_timeout() -> void:
	print("Atacou")
	if morto or ataques.size() == 0: return
	
	timer_ataque.stop()
	var ataque_sorteado = ataques.pick_random()
	
	if has_method(ataque_sorteado):
		call(ataque_sorteado)

func finalizar_ataque() -> void:
	if not morto:
		anim.play("Idle")
		timer_ataque.start()

func revelar_barra():

	vida_atual = vida_base * RunData.mult_dificuldade
	print("Vida Base do Boss: ", vida_base)
	print("Vida Atual Calculada: ", vida_atual)
	
	barra_vida.max_value = vida_base
	barra_vida.value = vida_atual
	

	$CanvasBoss.visible = true
	
	barra_vida.value = 0
	var tween = create_tween()
	tween.tween_property(barra_vida, "value", vida_atual, 4.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
	
func atualizar_barra():
	var tween = create_tween()
	tween.tween_property(barra_vida, "value", vida_atual, 0.2)

func receber_dano(quantidade):
	if morto: return
	print("Dano do boss: ", quantidade)
	vida_atual -= quantidade
	atualizar_barra() 
	
	if vida_atual <= 0:
		morto = true
		print("BOSS MORREU!")
