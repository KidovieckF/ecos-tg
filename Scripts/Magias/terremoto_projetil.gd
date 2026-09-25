extends Area2D

var dano_bala
var speed
var inimigos_lista = []
var direction 
var dano_add
var indice_atual = 0
var caminho : Array
var ticks = 0
var e_critico :bool
var velocidade_tick

func _ready() -> void:
	var raio = 20
	var posicao_mouse = get_global_mouse_position()
	global_position = posicao_mouse + Vector2(randf_range(-raio, raio), randf_range(-raio, raio))
	
	var multiplicador_velocidade = 1.0 + velocidade_tick

	$Timer.wait_time = $Timer.wait_time / multiplicador_velocidade 
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start(dano, critico, velocidade):
	dano_bala = dano
	e_critico = critico
	velocidade_tick = velocidade
	

func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		print("entrou")
		inimigos_lista.append(area)


func _on_area_exited(area: Area2D) -> void:
	inimigos_lista.erase(area)


func _on_timer_timeout() -> void:
	ticks +=1
	scale *= 1.5 
	if ticks >= 3:
		queue_free()
	for inimigos in inimigos_lista:
		var dano_tick = dano_bala * ticks
		var cor = Color.WHITE
		if e_critico:
			cor = Color.YELLOW
		inimigos.take_damage(dano_tick, cor, e_critico)
		if RunData.armas[0] != null:
			for upgrade in RunData.armas[0].upgrades_ativos:
				if upgrade.has_method("ao_causar_dano"):
					upgrade.ao_causar_dano(inimigos, dano_tick, self)

		
		
