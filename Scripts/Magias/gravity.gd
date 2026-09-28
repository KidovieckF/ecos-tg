extends Area2D

var dentro = false
var inimigos_dentro = []
var bala_speed = 0
var bala_dano = 0
var direcao_bala = Vector2.ZERO
var e_critico :bool

func  _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	position += direcao_bala * bala_speed * delta
	
	
	var centro_global = global_position
	if inimigos_dentro.size() > 0:
		for inimigo in inimigos_dentro:
			if is_instance_valid(inimigo):
				var direcao = (centro_global - inimigo.owner.global_position).normalized()
				inimigo.get_parent().position += direcao * 150 * delta
			
func _on_area_entered(area: Node2D) -> void:
	if area.owner != null and area.owner.is_in_group("Inimigos"):
		inimigos_dentro.append(area)
		dentro = true
		
func start(dano, player_pos, speed, direcao, critico):
	bala_speed = speed
	bala_dano = dano
	direcao_bala = direcao
	e_critico = critico


func _on_area_exited(area: Node2D) -> void:
	if area.owner != null and area.owner.is_in_group("Inimigos"):
		inimigos_dentro.erase(area)


func _on_tic_dano_timeout() -> void:
	for i in inimigos_dentro:
		if is_instance_valid(i):
			var cor = Color.WHITE
			if e_critico:
				cor = Color.YELLOW
			i.take_damage(bala_dano, cor, e_critico)
			if RunData.armas[0] != null:
				for upgrade in RunData.armas[0].upgrades_ativos:
					if upgrade.has_method("ao_causar_dano"):
						upgrade.ao_causar_dano(i.get_parent(), bala_dano, self)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Inimigos"):
		bala_speed = 0


func _on_duracao_timeout() -> void:
	queue_free()
