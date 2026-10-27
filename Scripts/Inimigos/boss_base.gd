extends CharacterBody2D

signal morreu

var cena_drop_artefato = preload("res://Cenas/Artefatos/Artefato_drop.tscn")

@export var nome_boss : String = "Chefe Gigante"
@export var vida_base : float = 5000.0
@export var ataques : Array[String] = []
@export var tempo_entre_ataques : float = 3.0 

var vida_max : float
var vida_atual : float
var morto = false
var tween_barra: Tween

@onready var timer_ataque = $TimerAtaque
@onready var barra_vida = $CanvasBoss/ProgressBar
@onready var anim = $AnimationPlayer

func _ready() -> void:
	add_to_group("Boss")
	add_to_group("Inimigos")
	vida_max = vida_base * RunData.mult_dificuldade
	vida_atual = vida_max
	barra_vida.max_value = vida_atual
	barra_vida.value = vida_atual
	
	timer_ataque.wait_time = tempo_entre_ataques
	anim.play("Idle")

func _on_timer_ataque_timeout() -> void:
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
	barra_vida.max_value = vida_atual
	barra_vida.value = 0
	$CanvasBoss.visible = true
	
	if tween_barra and tween_barra.is_running():
		tween_barra.kill()
	tween_barra = create_tween()
	tween_barra.tween_property(barra_vida, "value", vida_atual, 4.0).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)

func atualizar_barra():
	if tween_barra and tween_barra.is_running():
		tween_barra.kill()
	tween_barra = create_tween()
	tween_barra.tween_property(barra_vida, "value", vida_atual, 0.2)

func dropar_recompensa():
	var artefato_sorteado = RunData.sortear_artefato_por_pesos(RunData.PESOS_BOSS)
	if artefato_sorteado != null:
		var drop_art = cena_drop_artefato.instantiate()
		drop_art.global_position = global_position
		get_parent().add_child(drop_art)
		drop_art.configurar(artefato_sorteado)

func take_damage(quantidade, _cor = Color.WHITE, _critico = false, _ativa_artefatos = true):
	receber_dano(quantidade)

func receber_dano(quantidade):
	if morto: return
	vida_atual -= quantidade
	atualizar_barra() 
	
	if vida_atual <= 0:
		morto = true
		morreu.emit()
		dropar_recompensa()
