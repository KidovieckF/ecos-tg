extends Area2D

signal coletado(valor)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		coletado.emit(5)
		queue_free() # Replace with function body.
