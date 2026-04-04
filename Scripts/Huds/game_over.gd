extends CanvasLayer

func _ready():
	Engine.time_scale = 0 #

func _on_nascer_pressed() -> void:
	Engine.time_scale = 1
	queue_free()
	get_tree().call_deferred("reload_current_scene")
	
