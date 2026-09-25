extends CharacterBody2D

var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")
var morto = false
var dano_pendente = 0


func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass

func take_damage(quantidade, cor = Color.WHITE, critico = false):
	var novo_dano = ind_dano.instantiate() 
	
	get_parent().add_child(novo_dano)
	novo_dano.global_position = global_position
	RunData.sinal_dano_causado.emit(quantidade, global_position)
	if critico:
		print("Conectados: ", RunData.sinal_critico.get_connections()) 
		RunData.sinal_critico.emit(quantidade, global_position)
		novo_dano.scale = Vector2(2, 2)
		print("Critou")
	novo_dano._mostrar_dano(quantidade, cor)
	
	


		
