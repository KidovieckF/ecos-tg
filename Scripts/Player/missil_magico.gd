extends CharacterBody2D

var speed_bala
var dano_bala
var direction 
var q_projeteis
var indice_projetil
var config_mask
var bounces
var perfurante_cena

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atirei")
	config_mask = collision_mask
	print(global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$Sprite2D.play("default")
	rotation = direction.angle()
	
	var colisao = move_and_collide(direction * speed_bala * delta)
	
	if colisao:
		var alvo = colisao.get_collider()
		if alvo.has_method("take_damage") and not alvo.is_in_group("Players"):
			alvo.take_damage(dano_bala, Color.WHITE)
			if not perfurante_cena:
				queue_free()
		else:
			if bounces == 0:
				queue_free()
			else: 
				direction = direction.bounce(colisao.get_normal())
				position += colisao.get_normal() * 10
				bounces -= 1
			


	
	
func start(dano, speed, projeteis, indice, bounce, perfurante):
	bounces = bounce
	indice_projetil = indice
	q_projeteis = projeteis
	dano_bala = dano
	speed_bala = speed
	perfurante_cena = perfurante
	direction = (get_global_mouse_position() - global_position).normalized()
	var desvio = (indice_projetil - (q_projeteis - 1) / 2.0) * 20.0
	direction = direction.rotated(deg_to_rad(desvio))
	$Destruir.start()
	


func _on_destruir_timeout() -> void:
	queue_free()
