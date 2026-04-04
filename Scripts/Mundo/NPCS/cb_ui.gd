extends CanvasLayer


var lista_atual = []
var indice = 0
var resposta = false
var resp = 0
var recurso_atual

func _ready():
	pass
	
func _process(delta: float) -> void:
	if not resposta:
		if Input.is_action_just_pressed("Interagir"):
			if indice < lista_atual.size():
				mostrar_dialogo()
			else:
				queue_free()
		
func pegar_dialogo(lista : Array[FalaRecurso]):
	lista_atual = lista
	
func mostrar_dialogo():
	recurso_atual = lista_atual[indice]
	if recurso_atual.respostas.size() == 0:
		%Label2.text = recurso_atual.falas
		%resposta1.visible = false
		%resposta2.visible = false
		indice +=1
		
	else:
		%Label2.text = recurso_atual.falas
		%resposta1.visible = true
		%resposta1.text = recurso_atual.respostas[0]
		%resposta2.visible = true
		%resposta2.text = recurso_atual.respostas[1]
		resposta = true
		indice +=1

	
	
func _on_resposta_1_pressed() -> void:
	if resposta and indice < lista_atual.size():
		var nova_lista = recurso_atual.proximo_1
		if nova_lista.size() > 0:
			indice = 0
			pegar_dialogo(recurso_atual.proximo_1)
			mostrar_dialogo()
			resposta = false
		else:
			queue_free()
		
	else:
		queue_free()



func _on_resposta_2_pressed() -> void:
	if resposta and indice < lista_atual.size():
		var nova_lista = recurso_atual.proximo_2
		if nova_lista.size() > 0:
			indice = 0
			pegar_dialogo(recurso_atual.proximo_2)
			mostrar_dialogo()
			resposta = false
		else:
			queue_free()
		
	else:
		queue_free()
