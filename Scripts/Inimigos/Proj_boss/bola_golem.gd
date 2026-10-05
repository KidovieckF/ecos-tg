extends Area2D

@export var dano : float = 20.0
@export var tempo_de_aviso : float = 1.5

func _ready() -> void:
	monitoring = false 
	
	$Sombra.modulate.a = 0.2
	var tween = create_tween()
	tween.tween_property($Sombra, "modulate:a", 1.0, tempo_de_aviso)
	tween.tween_callback(cair_pedra)

func cair_pedra():
	$Sombra.visible = false
	
	$Pedra.position.y = -800
	$Pedra.visible = true
	
	var tween = create_tween()
	


	tween.tween_property($Pedra, "position:y", 0.0, 0.15).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	
	tween.tween_callback(bater_no_chao)

func bater_no_chao():
	monitoring = true 
	
	var corpos = get_overlapping_bodies()
	for corpo in corpos:
		if corpo.is_in_group("Players") and corpo.has_method("take_damage"):
			corpo.take_damage(dano, Color.RED)
			
	await get_tree().create_timer(0.5).timeout
	queue_free()
