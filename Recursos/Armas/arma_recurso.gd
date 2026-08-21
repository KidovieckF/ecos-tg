extends Resource
class_name ArmaRecurso

@export var nome : String
@export var dano : float
@export var speed : float
@export var  projetil : PackedScene
@export var efeito : PackedScene
@export var textura : Texture
@export var tags : Array[String]
@export var barra_ultimate : float
var barra_ultimate_atual : float
var upgrades_ativos : Array[UpgradeData] = []


func usar_ultimate(player,delta,dano_adicional, dano_multiplicador, direcao):
	pass


func usar_arma(player,delta,dano_adicional, dano_multiplicador, direcao):
	pass

func parar_uso(player):
	pass

func tem_efeito(nome_do_efeito : String) -> bool:
	for upg in upgrades_ativos:
		if upg.efeito == nome_do_efeito:
			return true
	return false
# Isso ajuda a perguntar: "Quantos tiros a mais eu tenho?"
func valor_do_efeito(nome_do_efeito : String) -> float:
	var total = 0.0
	for upg in upgrades_ativos:
		if upg.efeito == nome_do_efeito:
			total += upg.valor
	return total
