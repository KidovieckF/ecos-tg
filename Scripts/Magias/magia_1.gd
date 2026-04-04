extends Area2D

var dano_bala
var speed

var direction 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atirei")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * RecursosGlobais.velo_proje * delta


func start(pos, dir, dano, speed):
	position = pos
	direction = dir 
	dano_bala = dano


func _on_body_entered(body: Node2D) -> void:
	print("sumiu")
	if body.has_method("take_damage"):
		body.take_damage(dano_bala)
	queue_free()
