extends Node

var moeda = 0

var arma_escolhida : Resource


func ganhar_moeda(valor):
	moeda += valor
	SaveManager.registrar_moedas(valor)
	print("ganhou: ", moeda)
	
func gastar_moeda(valor):
	moeda -= valor
