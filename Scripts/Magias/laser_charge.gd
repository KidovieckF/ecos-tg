extends Node2D

var player_som: AudioStreamPlayer

func _ready() -> void:
	$AnimatedSprite2D.play("default")
	$Charge.play("RESET")
	player_som = AudioManager.tocar_sfx_charge(AudioManager.SFX_CHARGE, 3.6, -2.0)

func _exit_tree() -> void:
	# No instante em que o laser é disparado ou cancelado, mata o som na hora
	if is_instance_valid(player_som):
		player_som.stop()
		player_som.queue_free()
