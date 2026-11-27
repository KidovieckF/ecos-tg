extends Area2D

var speed = 500
var direction = Vector2.ZERO
var tempo_vida: float = 0.0

func _process(delta: float) -> void:
	global_position += direction * speed * delta
	tempo_vida += delta
	if tempo_vida > 3.5:
		queue_free()

func start(pos: Vector2, dir: Vector2):
	global_position = pos
	direction = dir 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players") and body.has_method("take_damage"):
		body.take_damage(2)
		queue_free()
	elif body is TileMap or body is TileMapLayer or body is StaticBody2D:
		queue_free()
