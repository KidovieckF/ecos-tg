extends Area2D

var dentro = false
var inimigos_dentro = []
var bala_speed = 0
var bala_dano = 0
var direcao_bala = Vector2.ZERO
var e_critico : bool

func _ready() -> void:
	AudioManager.tocar_sfx_charge(AudioManager.SFX_GRAVITY, 3.6, -2.0)

func _physics_process(delta: float) -> void:
	global_position += direcao_bala * bala_speed * delta
	
	var centro_global = global_position
	if inimigos_dentro.size() > 0:
		for inimigo in inimigos_dentro:
			if is_instance_valid(inimigo):
				var entidade = inimigo.owner if inimigo.owner != null else inimigo.get_parent()
				if entidade and not entidade.is_in_group("Boss"):
					var direcao = (centro_global - entidade.global_position).normalized()
					entidade.global_position += direcao * 150 * delta

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		if not inimigos_dentro.has(area):
			inimigos_dentro.append(area)
			dentro = true
			var cor = Color.YELLOW if e_critico else Color.WHITE
			area.take_damage(bala_dano, cor, e_critico)
			_aplicar_upgrades(area)

func start(dano, _player_pos, speed, direcao, critico):
	bala_speed = speed
	bala_dano = dano
	direcao_bala = direcao
	e_critico = critico

func _on_area_exited(area: Area2D) -> void:
	if inimigos_dentro.has(area):
		inimigos_dentro.erase(area)

func _on_tic_dano_timeout() -> void:
	for i in inimigos_dentro:
		if is_instance_valid(i):
			var cor = Color.YELLOW if e_critico else Color.WHITE
			i.take_damage(bala_dano, cor, e_critico)
			_aplicar_upgrades(i)

func _aplicar_upgrades(area: Area2D) -> void:
	if RunData.armas.size() > 0 and RunData.armas[0] != null:
		var entidade = area.owner if area.owner != null else area.get_parent()
		for upgrade in RunData.armas[0].upgrades_ativos:
			if upgrade.has_method("ao_causar_dano"):
				upgrade.ao_causar_dano(entidade, bala_dano, self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.is_in_group("Inimigos") and not body.is_in_group("Boss"):
		bala_speed = 0

func _on_duracao_timeout() -> void:
	queue_free()
