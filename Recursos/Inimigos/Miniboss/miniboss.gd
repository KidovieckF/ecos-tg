extends Resource
class_name miniboss_data

@export var Nome : String
@export var vida : float
@export var textura : Texture2D
@export var dano : float
@export var speed : float
@export var projetil : PackedScene
@export var tem_acao : bool
@export var peso_spawn : int
@export var exp : float
@export var dano_melee : float

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	pass

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	pass

func cutscene_inicial(inimigo: CharacterBody2D):
	pass
