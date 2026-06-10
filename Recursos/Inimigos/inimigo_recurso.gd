extends Resource
class_name inimigo_data

@export var Nome : String
@export var vida : int
@export var textura : Texture2D
@export var dano : float
@export var speed : float
@export var projetil : PackedScene
@export var tem_acao : bool
@export var peso_spawn : int
@export var exp : float

func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	pass

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	pass
