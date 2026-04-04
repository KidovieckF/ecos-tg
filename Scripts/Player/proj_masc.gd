extends Area2D

var direction 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atirei")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * RecursosGlobais.velo_proje * delta


func start(pos, dir):
	position = pos
	direction = dir 


func _on_body_entered(body: Node2D) -> void:
	print("sumiu")
	if body.has_method("take_damage"):
		body.take_damage(1)
	queue_free()
