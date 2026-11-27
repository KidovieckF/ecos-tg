extends Resource
class_name MascoteRucurso

@export var nome : String
@export var descricao : String
@export var dano : float
@export var preco : int = 50
@export var projetil : PackedScene
@export var textura : Texture2D



func movimentacao(mascote_body, player):
	pass

func atacar(mascote_body, inimigo):
	pass
