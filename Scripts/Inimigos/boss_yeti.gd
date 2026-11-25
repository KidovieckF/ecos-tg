extends "res://Scripts/Inimigos/boss_base.gd"

var cena_bola_neve = preload("res://Cenas/Inimigos/Bosses/Bola_neve.tscn")
@onready var player = get_tree().get_first_node_in_group("Players")
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_encontro: Area2D = get_node_or_null("AreaEncontro")

var em_corrida: bool = false
var dir_corrida: Vector2 = Vector2.ZERO
var vel_corrida: float = 460.0
var ja_deu_encontrao: bool = false

func _ready() -> void:
	nome_boss = "Yeti"
	ataques = ["ataque_lancamento", "ataque_pulo", "ataque_corrida"]
	super()
	
	sprite.play("Idle")
	morreu.connect(_ao_morrer)
	
	if area_encontro:
		area_encontro.monitoring = false
		area_encontro.body_entered.connect(_on_encontrao_body_entered)
		
	cutscene_inicial()

func cutscene_inicial() -> void:
	timer_ataque.stop()
	if player:
		player.set_physics_process(false)
		await get_tree().create_timer(1.2).timeout
		if player.has_node("CameraJogo"):
			player.get_node("CameraJogo").tremor(250)
		revelar_barra()
		await get_tree().create_timer(1.5).timeout
		player.set_physics_process(true)
	timer_ataque.start()

func _physics_process(delta: float) -> void:
	if morto:
		return
	if em_corrida:
		velocity = dir_corrida * vel_corrida
		move_and_slide()
		if is_on_wall():
			em_corrida = false
			velocity = Vector2.ZERO

func _olhar_para_player() -> void:
	if player:
		# No yeti.png os sprites olham para a direita por padrão
		sprite.flip_h = (player.global_position.x < global_position.x)

# 1. LANÇAMENTO DA BOLA DE NEVE
func ataque_lancamento() -> void:
	if not player:
		_voltar_idle()
		return
		
	_olhar_para_player()
	sprite.play("Lancamento")
	
	# Aguarda o momento do braço jogar a bola (ajuste o tempo conforme a velocidade da sua animação)
	await get_tree().create_timer(0.45).timeout
	if morto: return
	
	var bola = cena_bola_neve.instantiate()
	get_parent().add_child(bola)
	var dir = global_position.direction_to(player.global_position)
	bola.iniciar_tiro(global_position + dir * 40.0, dir, 18.0 * RunData.mult_dificuldade, 1.0)
	
	await get_tree().create_timer(0.5).timeout
	_voltar_idle()

# 2. PULO + CHUVA DE BOLAS MENORES AO CAIR NO CHÃO
func ataque_pulo() -> void:
	if not player:
		_voltar_idle()
		return
		
	_olhar_para_player()
	sprite.play("Pulo")
	
	var destino = player.global_position
	var duracao_pulo = 0.75
	
	# Move até o alvo enquanto faz um arco vertical só no sprite
	var tween_pos = create_tween()
	tween_pos.tween_property(self, "global_position", destino, duracao_pulo).set_trans(Tween.TRANS_SINE)
	
	var tween_altura = create_tween()
	tween_altura.tween_property(sprite, "position:y", -70.0, duracao_pulo * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween_altura.tween_property(sprite, "position:y", 0.0, duracao_pulo * 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	await tween_pos.finished
	if morto: return
	
	# Impacto no chão!
	if player.has_node("CameraJogo"):
		player.get_node("CameraJogo").tremor(240)
		
	# Faz cair de 8 a 10 bolas menores espalhadas pela área
	for i in range(9):
		var bola_menor = cena_bola_neve.instantiate()
		get_parent().add_child(bola_menor)
		var offset = Vector2.from_angle(randf() * TAU) * randf_range(70.0, 320.0)
		bola_menor.iniciar_queda(global_position + offset, 12.0 * RunData.mult_dificuldade, 0.45)
		
	await get_tree().create_timer(0.8).timeout
	_voltar_idle()

# 3. CORRIDA PARA DAR ENCONTRÃO NO PLAYER
func ataque_corrida() -> void:
	if not player:
		_voltar_idle()
		return
		
	_olhar_para_player()
	# Pausa rápida de aviso antes de disparar
	await get_tree().create_timer(0.4).timeout
	if morto: return
	
	dir_corrida = global_position.direction_to(player.global_position)
	sprite.flip_h = (dir_corrida.x < 0)
	sprite.play("Corrida")
	
	ja_deu_encontrao = false
	if area_encontro:
		area_encontro.monitoring = true
	em_corrida = true
	
	await get_tree().create_timer(1.1).timeout
	
	em_corrida = false
	velocity = Vector2.ZERO
	if area_encontro:
		area_encontro.monitoring = false
		
	await get_tree().create_timer(0.5).timeout
	_voltar_idle()

func _on_encontrao_body_entered(body: Node2D) -> void:
	if em_corrida and not ja_deu_encontrao and body.is_in_group("Players"):
		ja_deu_encontrao = true
		if body.has_method("take_damage"):
			body.take_damage(22.0 * RunData.mult_dificuldade, Color.CYAN)

func _voltar_idle() -> void:
	if not morto:
		sprite.play("Idle")
		timer_ataque.start()

func _ao_morrer() -> void:
	em_corrida = false
	velocity = Vector2.ZERO
	if area_encontro:
		area_encontro.monitoring = false
	timer_ataque.stop()
	sprite.stop()
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.6)
	tween.tween_callback(queue_free)
