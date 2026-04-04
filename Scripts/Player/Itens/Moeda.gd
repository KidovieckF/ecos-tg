extends Area2D

signal coletado
var valor = 2
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		RecursosGlobais.ganhar_moeda(valor)
		coletado.emit()
		queue_free() # Replace with function body.
