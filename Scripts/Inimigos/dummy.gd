extends CharacterBody2D

var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")
var morto = false
var dano_pendente = 0

@onready var hurtbox = get_node_or_null("Hurtbox")

func _ready() -> void:
	add_to_group("Dummies")
	atualizar_estado_hurtbox()


func atualizar_estado_hurtbox() -> void:
	if hurtbox:
		hurtbox.set_deferred("monitorable", RunData.treino_liberado)
		hurtbox.set_deferred("monitoring", RunData.treino_liberado)
		
		modulate.a = 1.0 if RunData.treino_liberado else 0.4


func liberar_para_treino() -> void:
	atualizar_estado_hurtbox()


func take_damage(quantidade, cor = Color.WHITE, critico = false):
	var novo_dano = ind_dano.instantiate() 
	get_parent().add_child(novo_dano)
	novo_dano.global_position = global_position
	
	RunData.sinal_dano_causado.emit(quantidade, global_position)
	if critico:
		RunData.sinal_critico.emit(quantidade, global_position)
		novo_dano.scale = Vector2(2, 2)
		
	novo_dano._mostrar_dano(quantidade, cor)
