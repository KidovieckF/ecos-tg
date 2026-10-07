extends Area2D


var direction
var speed = 200
func _ready() -> void:
	pass 

func _process(delta: float) -> void:
	position += direction * speed * delta

func start(pos, dir):
	position = pos
	direction = dir 

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(2)
	queue_free()
