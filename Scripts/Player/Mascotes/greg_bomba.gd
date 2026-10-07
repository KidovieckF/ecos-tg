extends Area2D

var dano_bomba = 2
@onready var sprite = $Sprite2D
@onready var colisao = $CollisionShape2D


var cena_explosao = preload("res://Cenas/Efeitos/explosao_Effect.tscn") 

func lancar(alvo_posicao: Vector2, dano_recebido: float):
	dano_bomba = dano_recebido
	
	var tempo_voo = 0.8
	var altura_arco = -150.0 
	
	var tween_chao = create_tween()
	tween_chao.tween_property(self, "global_position", alvo_posicao, tempo_voo)
	
	var tween_arco = create_tween().set_trans(Tween.TRANS_QUAD)
	tween_arco.tween_property(sprite, "position:y", altura_arco, tempo_voo / 2.0).set_ease(Tween.EASE_OUT)
	tween_arco.tween_property(sprite, "position:y", 0.0, tempo_voo / 2.0).set_ease(Tween.EASE_IN)
	
	
	tween_arco.finished.connect(explodir)

func explodir():

	colisao.set_deferred("disabled", false)
	await get_tree().process_frame 
	
	var alvos = get_overlapping_areas()
	for area in alvos:
		print("Alvo: ", alvos)
		if area.owner != null and area.owner.is_in_group("Inimigos"):
			print("TESTE DE DANOOO")
			area.take_damage(dano_bomba)

	var arte_explosao = cena_explosao.instantiate()
	get_parent().add_child(arte_explosao)
	arte_explosao.scale *= 2
	arte_explosao.global_position = global_position
	arte_explosao.play("default") 
	arte_explosao.animation_finished.connect(arte_explosao.queue_free)
	queue_free()
