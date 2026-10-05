extends Node2D

@export var tempo_de_aviso : float = 1.5

func _ready() -> void:
	$pedra_voadora.visible = false
	$pedra_voadora.monitoring = false
	
	$ColorRect.modulate.a = 0.2
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate:a", 1.0, tempo_de_aviso)
	tween.tween_callback(disparar_pedra)

func disparar_pedra():
	$ColorRect.visible = false
	

	$pedra_voadora.visible = true
	$pedra_voadora.monitoring = true
	
	var tween_voo = create_tween()
	var destino = $pedra_voadora.position - Vector2(1300, 0)
	
	tween_voo.tween_property($pedra_voadora, "position", destino, 1.5)
	
	tween_voo.parallel().tween_property($pedra_voadora/Sprite2D, "rotation", -20.0, 1.5)
	
	tween_voo.tween_callback(queue_free)


func _on_pedra_voadora_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players") and body.has_method("take_damage"):
		body.take_damage(20, Color.RED)
