extends Area2D

var dentro = false
var inimigos_dentro = []
var bala_speed = 0
var bala_dano = 0
var direcao_bala = Vector2.ZERO

func  _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	position += direcao_bala * bala_speed * delta
	
	
	var centro_global = $Panel.global_position + $Panel.size / 2
	if inimigos_dentro.size() > 0:
		for inimigo in inimigos_dentro:
			if is_instance_valid(inimigo):
				var direcao = (centro_global - inimigo.global_position).normalized()
				inimigo.position += direcao * 100 * delta
			
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigos"):
		inimigos_dentro.append(body)
		dentro = true
		
func start(dano, player_pos, speed):
	bala_speed = speed
	bala_dano = dano
	direcao_bala = (get_global_mouse_position() - player_pos).normalized()
	


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Inimigos"):
		inimigos_dentro.erase(body)


func _on_tic_dano_timeout() -> void:
	for i in inimigos_dentro:
		print(bala_dano)
		i.take_damage(bala_dano, Color.WHITE)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Inimigos"):
		bala_speed = 0


func _on_duracao_timeout() -> void:
	queue_free()
