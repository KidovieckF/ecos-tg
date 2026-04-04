extends Label

var tween
  

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	pass


func _mostrar_dano(dano, color = Color.WHITE):
	print("dano ", dano)
	$".".modulate = color
	$".".text = "%.0f" % dano
	var num_ale = randf_range(-10, 10)
	global_position.x += num_ale
	num_ale = randf_range(-10, 10)
	global_position.y += num_ale
	tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 50, 1)
	tween.tween_callback(queue_free)
