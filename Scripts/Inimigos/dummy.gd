extends CharacterBody2D

var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")



func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass

func take_damage(quantidade, cor = Color.WHITE):
	var novo_dano = ind_dano.instantiate() 
	novo_dano.global_position = global_position
	novo_dano._mostrar_dano(quantidade, cor)
	get_parent().add_child(novo_dano)
	


		
