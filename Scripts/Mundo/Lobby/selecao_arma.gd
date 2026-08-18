extends Control

@export var armas : Array[ArmaRecurso]
var index = 0


func _ready() -> void:
	%ArmaBtn.texture_normal = armas[index].textura

func _on_esquerda_btn_pressed() -> void:
	index -=1
	if index < 0:
		index = 0
	atualizar_textura()

func _on_arma_btn_pressed() -> void:
	if RunData.armas[0] == null:
		RunData.armas[0] = armas[index]
	elif RunData.armas[1] == null:
		RunData.armas[1] = armas[index]
	else:
		# Se as duas estiverem cheias, substitui a arma principal
		RunData.armas[0] = armas[index]
	queue_free()
	
func _on_direita_btn_pressed() -> void:
	if index < (armas.size() - 1):
		index +=1
		atualizar_textura()
	else: 
		return
		
	
func atualizar_textura():
	%ArmaBtn.texture_normal = armas[index].textura


func _on_fechar_btn_pressed() -> void:
	queue_free()
