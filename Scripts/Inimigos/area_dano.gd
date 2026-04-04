extends Area2D

@export var dano : int 
var player_na_area = false
var player


func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	
	if body.has_method("take_damage") and body.is_in_group("Players"):
		player_na_area = true
		player = body
		player.take_damage(dano)
		$Timer.start()

func _on_timer_timeout() -> void:
		if player_na_area:
			player.take_damage(dano)
			$Timer.start()


func _on_body_exited(body: Node2D) -> void:
	player_na_area = false
