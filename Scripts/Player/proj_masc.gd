extends Area2D

var direction 
var dano_atual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Atirei")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * 300 * delta


func start(pos, dir, dano):
	position = pos
	direction = dir 
	dano_atual = dano


func _on_body_entered(body: Node2D) -> void:
	print("sumiu")
	if body.has_method("take_damage"):
		body.take_damage(dano_atual)
	queue_free()
