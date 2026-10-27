extends Area2D

var dano_bala: float = 0.0
var speed: float = 0.0
var inimigos_lista: Array = []
var direction: Vector2 = Vector2.ZERO
var dano_add: float = 0.0
var indice_atual: int = 0
var caminho: Array = []
var ticks: int = 0
var e_critico: bool = false
var velocidade_tick: float = 0.0

func _ready() -> void:
	var raio = 20
	var posicao_mouse = get_global_mouse_position()
	global_position = posicao_mouse + Vector2(randf_range(-raio, raio), randf_range(-raio, raio))
	
	$Sprite2D.visible = false
	$Panel.visible = true
	
	var multiplicador_velocidade = 1.0 + velocidade_tick
	$Timer.wait_time = $Timer.wait_time / multiplicador_velocidade 
	$Timer.start()

func start(dano, critico, velocidade):
	dano_bala = dano
	e_critico = critico
	velocidade_tick = velocidade

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		inimigos_lista.append(area)

func _on_area_exited(area: Area2D) -> void:
	inimigos_lista.erase(area)

func _on_timer_timeout() -> void:
	ticks += 1
	
	if ticks == 1:
		$Panel.visible = false           
		$Sprite2D.visible = true      
		$Sprite2D.frame = 0        
	elif ticks == 2:
		$Sprite2D.frame = 1         
		scale *= 1.35                
	elif ticks == 3:
		$Sprite2D.frame = 2         
		scale *= 1.35                
	
	_tocar_som_impacto_tick()
	
	for inimigos in inimigos_lista:
		if is_instance_valid(inimigos):
			var dano_tick = dano_bala * ticks
			var cor = Color.WHITE
			if e_critico:
				cor = Color.YELLOW
			inimigos.take_damage(dano_tick, cor, e_critico)
			if RunData.armas[0] != null:
				for upgrade in RunData.armas[0].upgrades_ativos:
					if upgrade.has_method("ao_causar_dano"):
						upgrade.ao_causar_dano(inimigos, dano_tick, self)
	
	if ticks >= 3:
		$Timer.stop()

		$CollisionShape2D.set_deferred("disabled", true)
		
		
		var tween = create_tween()
		tween.tween_interval(1.2) 
		tween.tween_property(self, "modulate:a", 0.0, 0.4) 
		tween.tween_callback(queue_free)


func _tocar_som_impacto_tick() -> void:
	var duracao_tick = $Timer.wait_time
	var pitch = clamp(1.0 + (velocidade_tick * 0.15) + randf_range(-0.04, 0.04), 0.85, 1.6)
	var volume = -3.0 + (ticks * 1.0)
	var pontos_inicio = [1.2, 3.8, 6.0]
	var ponto_atual = pontos_inicio[clamp(ticks - 1, 0, 2)]
	
	AudioManager.tocar_sfx_com_duracao(AudioManager.SFX_IMPACTO_CHAO, duracao_tick, volume, pitch, ponto_atual)
