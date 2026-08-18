extends CanvasLayer

#Upgrade
var upg_de_dano = preload("res://Recursos/Upgrades/Dano.tres")
var upg_de_speed = preload("res://Recursos/Upgrades/Speed.tres")
var upg_de_tamanho = preload("res://Recursos/Upgrades/Tamanho.tres")
var upg_de_multidisparo = preload("res://Recursos/Upgrades/Multidisparo.tres")
var upg_de_bounce = preload("res://Recursos/Upgrades/Bounce.tres")
var upg_de_pentracao = preload("res://Recursos/Upgrades/Penetracao.tres")
var upg_de_disparos = preload("res://Recursos/Upgrades/Disparos.tres")


var pagina = 1
@export var armas : Array[ArmaRecurso] = []

func _process(delta: float) -> void:
	if pagina > 1:
		%Voltar.visible = true
	else:
		%Voltar.visible = false


func _on_proximo_pressed() -> void:
	pagina += 1

func _on_voltar_pressed() -> void:
	pagina -= 1
	


func _on_arma_button_item_selected(index: int) -> void:
	var arma_escolhida = armas[index]
	RunData.armas[0] = arma_escolhida





func _on_dano_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_dano)
	RunData.armas[0].calcular_upgrades()
	


func _on_speed_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_speed)
	RunData.armas[0].calcular_upgrades()


func _on_proj_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_disparos)
	RunData.armas[0].calcular_upgrades()


func _on_disparo_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_multidisparo)
	RunData.armas[0].calcular_upgrades()


func _on_tamanho_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_tamanho)
	RunData.armas[0].calcular_upgrades()


func _on_bounce_line_text_submitted(new_text: String) -> void:
	var quantidade = new_text.to_int()
	for i in range(quantidade):
		RunData.armas[0].upgrades_ativos.append(upg_de_bounce)
	RunData.armas[0].calcular_upgrades()


func _on_penetracao_toggle_toggled(toggled_on: bool) -> void:
	RunData.armas[0].upgrades_ativos.append(upg_de_pentracao)
	RunData.armas[0].calcular_upgrades()
