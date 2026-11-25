extends Area2D

enum Modo { TIRO, QUEDA }
var modo_atual: Modo = Modo.TIRO

var direction: Vector2 = Vector2.ZERO
var speed: float = 340.0
var dano: float = 15.0

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if modo_atual == Modo.TIRO and direction != Vector2.ZERO:
		global_position += direction * speed * delta
		$Sprite2D.rotation += 8.0 * delta

func iniciar_tiro(pos: Vector2, dir: Vector2, p_dano: float = 15.0, escala: float = 1.0) -> void:
	modo_atual = Modo.TIRO
	global_position = pos
	direction = dir.normalized()
	dano = p_dano
	scale = Vector2(escala, escala)
	get_tree().create_timer(4.5).timeout.connect(func():
		if is_instance_valid(self): queue_free()
	)

func iniciar_queda(pos_alvo: Vector2, p_dano: float = 10.0, escala: float = 0.45) -> void:
	modo_atual = Modo.QUEDA
	scale = Vector2(escala, escala)
	dano = p_dano
	monitoring = false
	
	global_position = pos_alvo + Vector2(0, -450)
	var tempo_queda = randf_range(0.45, 0.7)
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", pos_alvo, tempo_queda).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(func():
		if not is_instance_valid(self): return
		monitoring = true
		
		for corpo in get_overlapping_bodies():
			if corpo.is_in_group("Players") and corpo.has_method("take_damage"):
				corpo.take_damage(dano, Color.CYAN)
				
		var t_out = create_tween()
		t_out.tween_property(self, "modulate:a", 0.0, 0.2)
		t_out.tween_callback(queue_free)
	)

func _on_body_entered(body: Node2D) -> void:
	if modo_atual != Modo.TIRO:
		return
		
	if body.is_in_group("Players"):
		if body.has_method("take_damage"):
			body.take_damage(dano, Color.CYAN)
		queue_free()
	elif not body.is_in_group("Boss") and not body.is_in_group("Inimigos"):
		# Bateu na parede
		queue_free()
