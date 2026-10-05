extends CharacterBody2D

@export var nome_boss : String = "Chefe Gigante"
@export var vida_base : float = 5000.0
@export var ataques : Array[String] = []
@export var tempo_entre_ataques : float = 3.0 

var vida_atual : float
var morto = false

@onready var timer_ataque = $TimerAtaque
@onready var sprite = $AnimatedSprite2D

func _ready() -> void:
	vida_atual = vida_base * RunData.mult_dificuldade
	timer_ataque.wait_time = tempo_entre_ataques
	timer_ataque.start()
	sprite.play("Idle")

func _on_timer_ataque_timeout() -> void:
	print("Atacou")
	if morto or ataques.size() == 0: return
	
	timer_ataque.stop()
	var ataque_sorteado = ataques.pick_random()
	
	if has_method(ataque_sorteado):
		call(ataque_sorteado)

func finalizar_ataque() -> void:
	if not morto:
		sprite.play("Idle")
		timer_ataque.start()
