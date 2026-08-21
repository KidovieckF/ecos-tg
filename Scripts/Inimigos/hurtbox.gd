extends Area2D

var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func take_damage(quantidade, cor = Color.WHITE):
	if owner.morto:
		return
		
	owner.dano_pendente += quantidade
	
	var novo_dano = ind_dano.instantiate() 
	owner.get_parent().add_child(novo_dano)
	novo_dano.global_position = owner.global_position
	novo_dano._mostrar_dano(quantidade, cor) 
	RunData.barra_ultimate_atual =  min((RunData.barra_ultimate_atual + (quantidade * 0.01)), RunData.barra_ultimate)
