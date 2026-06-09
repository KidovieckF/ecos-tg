extends Resource
class_name ArmaRecurso

@export var dano : float
@export var speed : float
@export var  projetil : PackedScene
@export var efeito : PackedScene
@export var textura : Texture

func usar_arma(player,delta,dano_mult,dano_add):
	pass

func parar_uso(player):
	pass
