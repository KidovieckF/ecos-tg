extends Area2D

var speed = 500
var direction 

func _process(delta: float) -> void:
	position += direction * speed * delta


func start(pos, dir):
	position = pos
	direction = dir 

func _on_body_entered(body: Node2D) -> void:
	print("sumiu")
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()
