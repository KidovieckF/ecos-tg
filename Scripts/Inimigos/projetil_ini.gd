extends Area2D

var speed: float = 400.0
var direction: Vector2 = Vector2.ZERO
var dano: float = 10.0

func _ready() -> void:
	get_tree().create_timer(5.0).timeout.connect(queue_free)

func _process(delta: float) -> void:
	if direction != Vector2.ZERO:
		global_position += direction * speed * delta
		rotation = direction.angle()

func start(pos: Vector2, dir: Vector2, p_dano: float = 10.0) -> void:
	global_position = pos
	direction = dir
	dano = p_dano

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		if body.has_method("take_damage"):
			body.take_damage(dano)
		queue_free()
	elif not body.is_in_group("Inimigos"):
		queue_free()
