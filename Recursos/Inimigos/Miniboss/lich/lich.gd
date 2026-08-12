extends miniboss_data
class_name inimigo_lich

var segunda_fase = false
var tipo_atk
var canalizando = false

func cutscene_inicial(inimigo: CharacterBody2D):
	canalizando = true
	inimigo.player.set_physics_process(false)
	await inimigo.get_tree().create_timer(2.0).timeout
	inimigo.player.get_node("CameraJogo").tremor(300)
	await inimigo.get_tree().create_timer(2.0).timeout
	inimigo.player.set_physics_process(true)
	canalizando = false
	


func movimento(inimigo: CharacterBody2D, delta: float) -> void:
	var direcao = inimigo.global_position.direction_to(inimigo.player.global_position)
	var distancia = inimigo.global_position.distance_to(inimigo.player.global_position)
	#if direcao:
	#	if direcao.x > 0: 
	#		inimigo.last_direction = direcao
	#		inimigo.get_node("Sprite2D").flip_h = false
	#		inimigo.get_node("Sprite2D").play("Andando")
	#	elif direcao.x < 0:
	#		inimigo.last_direction = direcao
	#		inimigo.get_node("Sprite2D").flip_h = true
	#		inimigo.get_node("Sprite2D").play("Andando")
	
	
	
	if segunda_fase and inimigo.get_node("SpecialActionTimer").is_stopped() and not canalizando:
		inimigo.global_position =  inimigo.player.global_position + (Vector2.RIGHT.rotated(randf_range(0, TAU)) * 80)
		inimigo.get_node("SpecialActionTimer").start()
		inimigo.get_node("AcaoTimer").start()
		ataque_garra(inimigo)
		
	if canalizando:
		inimigo.velocity = Vector2.ZERO
		inimigo.move_and_slide()
	else:
		if distancia > 60:
			inimigo.velocity = direcao * inimigo.data.speed
		else:
			inimigo.velocity = Vector2.ZERO
		inimigo.move_and_slide()

func acao(inimigo: CharacterBody2D, delta: float) -> void:
	if inimigo.vida_atual <= (inimigo.vida_max / 2) and not segunda_fase:
		segunda_fase = true
		speed *= 2
	atacar(inimigo)
	
func atacar(inimigo: CharacterBody2D):
	var atk = randi_range(1, 4)
	if not segunda_fase:
		if atk == 1 or atk == 2:
			ataque_garra(inimigo)
		else:
			ataque_corvos(inimigo)
	else:
		if atk == 1:
			ataque_garra(inimigo)
		elif atk == 2 or atk == 3:
			ataque_corvos(inimigo)
		elif atk == 4:
			ataque_tempestade_de_corvos(inimigo)

func ataque_tempestade_de_corvos(inimigo: CharacterBody2D):
	
	inimigo.get_node("AcaoTimer").start()
	tipo_atk = "tempestade"
	canalizando = true
	for i in range(20):
		for j in range(8):
			var espalhamento = randf_range(-5, 5)
			var novo_tiro = projetil.instantiate()
			inimigo.get_parent().add_child(novo_tiro)
			var direcao = Vector2.RIGHT.rotated(deg_to_rad(j * 45 + espalhamento))
			novo_tiro.global_position = inimigo.global_position
			novo_tiro.start(inimigo.global_position ,direcao)
		await inimigo.get_tree().create_timer(randf_range(0.01,0.08)).timeout
		
	inimigo.get_node("AcaoTimer").start()
	await inimigo.get_tree().create_timer(2.0).timeout
	canalizando = false
		
func ataque_garra(inimigo: CharacterBody2D):
	inimigo.get_node("AcaoTimer").start()
	print("Ataquei Garra")
	tipo_atk = "garra"
	canalizando = true
	await inimigo.get_tree().create_timer(0.5).timeout
	inimigo.get_node("AtaqueBase").look_at(inimigo.player.global_position)
	var formato_cone = ConvexPolygonShape2D.new()
	
	formato_cone.points = PackedVector2Array([
		Vector2(0, 0),     # Perto do chefe (origem)
		Vector2(100, -50), # Ponta superior
		Vector2(100, 50)   # Ponta inferior
	])
	inimigo.get_node("AtaqueBase/Polygon2D").polygon = formato_cone.points
	inimigo.get_node("AtaqueBase/Polygon2D").visible = true
	inimigo.get_node("AtaqueBase/CollisionShape2D").set_deferred("disabled", true)
	await inimigo.get_tree().create_timer(0.5).timeout
	inimigo.get_node("AtaqueBase/CollisionShape2D").shape = formato_cone
	inimigo.get_node("AtaqueBase/CollisionShape2D").set_deferred("disabled", false)
	inimigo.get_node("AtaqueBase/Polygon2D").visible = false
	await inimigo.get_tree().create_timer(0.5).timeout
	inimigo.get_node("AtaqueBase/CollisionShape2D").set_deferred("disabled", true)
	canalizando = false


func ataque_corvos(inimigo: CharacterBody2D):
	
	canalizando = true
	inimigo.get_node("AcaoTimer").start()
	tipo_atk = "corvos"
	var i = 0
	print("Iniciando animação FORTE")
	while i < 20:
		var espalhamento = randf_range(-5, 5)
		var novo_tiro = projetil.instantiate()
		inimigo.get_parent().add_child(novo_tiro)
		var direcao = (inimigo.player.global_position - inimigo.global_position).normalized().rotated(deg_to_rad(espalhamento))
		novo_tiro.global_position = inimigo.global_position
		novo_tiro.start(inimigo.global_position ,direcao)
		await inimigo.get_tree().create_timer(randf_range(0.01,0.08)).timeout
		i += 1
	canalizando = false
