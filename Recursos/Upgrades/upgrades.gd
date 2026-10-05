extends Resource
class_name UpgradeData

@export var valor : float = 0.0
@export var efeito : String = "null"
@export var tag : String = "null"
@export var textura : Texture2D 

@export var limite : int = -1 
@export var excludentes : Array[UpgradeData] = []
@export var armas_proibidas : Array[ArmaRecurso] = []

func ao_inimigo_morrer(inimigo, player):
	pass
	
func ao_atirar(player, direcao, bala_criada):
	pass
	
func ao_causar_dano(inimigo, dano, arma):
	pass
	
func ao_atualizar_jogador(player, delta):
	pass
