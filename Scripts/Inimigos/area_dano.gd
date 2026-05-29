extends Area2D

var dano_atual : int
var player_na_area = false
var player

func pegarDano(dano):
	dano_atual = dano

func _physics_process(delta: float) -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	
	if body.has_method("take_damage") and body.is_in_group("Players"):
		$"../Sprite2D".play("Atacando")
		player_na_area = true
		player = body
		player.take_damage(dano_atual)
		$Timer.start()

func _on_timer_timeout() -> void:
		if player_na_area:
			player.take_damage(dano_atual)
			$Timer.start()


func _on_body_exited(body: Node2D) -> void:
	player_na_area = false
