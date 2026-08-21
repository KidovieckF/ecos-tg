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
		if bounces == 0:
			queue_free()
		else: 
			direction = direction.bounce(colisao.get_normal())
			position += colisao.get_normal() * 10
			bounces -= 1
			


	
	
func start(dano, speed, projeteis, indice, bounce, perfurante, direcao):
	bounces = bounce
	indice_projetil = indice
	q_projeteis = projeteis
	dano_bala = dano
	speed_bala = speed
	perfurante_cena = perfurante
	direction = direcao
	var desvio = (indice_projetil - (q_projeteis - 1) / 2.0) * 20.0
	direction = direction.rotated(deg_to_rad(desvio))
	$Destruir.start()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(dano_bala, Color.WHITE)
		if not perfurante_cena:
			queue_free()

func _on_destruir_timeout() -> void:
	queue_free()
