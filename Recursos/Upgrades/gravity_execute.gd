extends UpgradeData
class_name UpgradeGravityExecute



func ao_inimigo_morrer(inimigo, player):
	var arma_ativa = RunData.armas[0]
	if inimigo.has_meta("morto_por_execute"):
		if not "limiar_execute" in arma_ativa:
			arma_ativa.limiar_execute = 0.01
		arma_ativa.limiar_execute += 0.001
		print("Bola de neve! O execute subiu para: ", arma_ativa.limiar_execute * 100, "%")
		
func ao_causar_dano(inimigo, dano, arma):
	
	var arma_ativa = RunData.armas[0]
	var limite_atual = 0.05
	
	if "limiar_execute" in arma_ativa:
		limite_atual = arma_ativa.limiar_execute
		
	var vida_para_executar = inimigo.vida_max * limite_atual 
	
	var vida_futura = inimigo.vida_atual
	if "dano_pendente" in inimigo:
		vida_futura -= inimigo.dano_pendente
	
	if vida_futura <= vida_para_executar:
		inimigo.set_meta("morto_por_execute", true)
		
		var hurtbox = inimigo.get_node_or_null("Hurtbox")
		if hurtbox:
			hurtbox.take_damage(999999, Color.PURPLE, false)
