extends Camera2D

@export var player : CharacterBody2D
var room_size = Vector2(1139, 641)
var forca_tremor = 0.0
var mapa_gen: Node = null

# <<< REGULE AQUI: Aumente se quiser a câmera ainda mais contida (ex: 220 ou 260) >>>
var margem_trilho: float = 220.0 

func _ready() -> void:
	top_level = true
	position_smoothing_enabled = false

func _physics_process(delta: float) -> void:
	if not player:
		return
		
	if not mapa_gen and get_tree().current_scene:
		mapa_gen = get_tree().current_scene.get_node_or_null("MapGenerator")
		
	var pos_player = player.global_position
	if pos_player.x < 0:
		pos_player.x = 0
		
	var indice = Vector2i(floor(pos_player / room_size))
	var centro = (Vector2(indice) * room_size) + (room_size / 2.0)
	
	var min_x = centro.x
	var max_x = centro.x
	var min_y = centro.y
	var max_y = centro.y
	var g_atual = 0
	
	if mapa_gen and mapa_gen.salas_criadas.has(indice):
		var sala_atual = mapa_gen.salas_criadas[indice]
		g_atual = sala_atual.grupo_id if "grupo_id" in sala_atual else 0
		
		if g_atual != 0:
			var alcance_x = max(0.0, (room_size.x / 2.0) + (room_size.x / 2.0 - margem_trilho))
			var alcance_y = max(0.0, (room_size.y / 2.0) + (room_size.y / 2.0 - margem_trilho))
			
			if eh_mesmo_grupo(indice + Vector2i(1, 0), g_atual):
				max_x = centro.x + alcance_x
			if eh_mesmo_grupo(indice + Vector2i(-1, 0), g_atual):
				min_x = centro.x - alcance_x
			if eh_mesmo_grupo(indice + Vector2i(0, 1), g_atual):
				max_y = centro.y + alcance_y
			if eh_mesmo_grupo(indice + Vector2i(0, -1), g_atual):
				min_y = centro.y - alcance_y

	var alvo = Vector2(
		clamp(pos_player.x, min_x, max_x),
		clamp(pos_player.y, min_y, max_y)
	)
	
	# BLOQUEIA A QUINA DO L: Se a diagonal for o abismo, não permite desvio nos dois eixos juntos
	if g_atual != 0:
		var desvio_x = alvo.x - centro.x
		var desvio_y = alvo.y - centro.y
		var dir_x = 1 if desvio_x > 0 else (-1 if desvio_x < 0 else 0)
		var dir_y = 1 if desvio_y > 0 else (-1 if desvio_y < 0 else 0)
		
		if dir_x != 0 and dir_y != 0:
			var pos_diag = indice + Vector2i(dir_x, dir_y)
			if not eh_mesmo_grupo(pos_diag, g_atual):
				if abs(desvio_x) >= abs(desvio_y):
					alvo.y = centro.y
				else:
					alvo.x = centro.x
	
	global_position = global_position.lerp(alvo, 8.0 * delta)

	if forca_tremor > 0:
		var forca_tremorx = randf_range(-forca_tremor, forca_tremor)
		var forca_tremory = randf_range(-forca_tremor, forca_tremor)
		offset = Vector2(forca_tremorx, forca_tremory)
		forca_tremor = lerp(forca_tremor, 0.0, 0.05)
	else:
		offset = Vector2.ZERO

func eh_mesmo_grupo(viz_pos: Vector2i, g_atual: int) -> bool:
	if mapa_gen and mapa_gen.salas_criadas.has(viz_pos):
		var sala = mapa_gen.salas_criadas[viz_pos]
		var g = sala.grupo_id if "grupo_id" in sala else 0
		return g != 0 and g == g_atual
	return false

func tremor(forca : float):
	forca_tremor = forca
