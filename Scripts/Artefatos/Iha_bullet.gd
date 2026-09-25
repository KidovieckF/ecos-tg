extends Area2D

var dano_bala
var speed
var direction 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer2D.play()
	$Sprite2D.play("default")
	await get_tree().create_timer(3.0).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if direction != null:
		global_position += direction * speed * delta
		
		# Opcional: Faz a bala "olhar" para onde está indo
		rotation = direction.angle()

func start(pos, dir, dano, velocidade):
	dano_bala = dano
	speed = velocidade
	position = pos
	direction = dir


func _on_area_entered(area: Area2D) -> void:
	if area.has_method("take_damage"):
		area.take_damage(dano_bala, Color.ORANGE, true, false)
		queue_free()
