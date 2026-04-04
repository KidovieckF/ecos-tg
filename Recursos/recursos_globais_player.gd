extends Node

var moeda = 0
var vidaMax = 3
var vidaAtual = 3
var dano = 1
var velo_proje = 500

func ganhar_moeda(valor):
	moeda += valor
	print("ganhou: ", moeda)
	
func gastar_moeda(valor):
	moeda -= valor
