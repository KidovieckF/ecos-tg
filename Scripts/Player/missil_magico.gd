extends CharacterBody2D

var fantasma_de_parede = false 

var speed_bala = 0
var dano_bala = 0
var direction = Vector2.RIGHT
var q_projeteis = 1
var indice_projetil = 0
var config_mask = 0
var bounces = 0
var perfurante_cena = false
var e_critico = false

func _ready() -> void:
	print("Atirei")
	config_mask = collision_mask
	print(global_position)

func _physics_process(delta: float) -> void:
	$Sprite2D.play("default")
	rotation = direction.angle()
	if fantasma_de_parede:
		position += direction * speed_bala * delta
	else:
		var colisao = move_and_collide(direction * speed_bala * delta)
		
		if colisao:
			if bounces == 0:
				queue_free()
			else: 
				direction = direction.bounce(colisao.get_normal())
				position += colisao.get_normal() * 10
				bounces -= 1
	
func start(dano, speed, projeteis, indice, bounce, perfurante, direcao, critico):
	bounces = bounce
	indice_projetil = indice
	q_projeteis = projeteis
	dano_bala = dano
	speed_bala = speed
	perfurante_cena = perfurante
	direction = direcao
	var desvio = (indice_projetil - (q_projeteis - 1) / 2.0) * 20.0
	direction = direction.rotated(deg_to_rad(desvio))
	e_critico = critico
	$Destruir.start()
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		var cor = Color.WHITE
		if e_critico:
			cor = Color.YELLOW
		area.take_damage(dano_bala, cor, e_critico)
		if not perfurante_cena:
			queue_free()

func _on_destruir_timeout() -> void:
	queue_free()
