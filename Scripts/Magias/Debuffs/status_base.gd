extends Node2D

class_name StatusBase

@export var debuff : DebuffsData

var dano_I 
var tempo 
var efeito 
var valor_efeito 
var stacka

func _ready() -> void:
	dano_I = debuff.dano
	tempo = debuff.tempo
	efeito = debuff.efeito
	valor_efeito = debuff.valor_efeito
	stacka = debuff.stacka
	
	$Timer.wait_time = tempo
	$Timer.start()
	


func _on_timer_timeout() -> void:
	queue_free()


func _on_timer_dano_timeout() -> void:
	pass # Replace with function body.
