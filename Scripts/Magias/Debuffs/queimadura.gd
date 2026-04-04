extends StatusBase

var stacks = 1
var cor = Color.RED

func _physics_process(delta: float) -> void:
	if $TimerDano.is_stopped():
		var dano_final = dano_I * stacks
		get_parent().take_damage(dano_final, Color.DARK_RED)
		print("dano queimadura", dano_final)
		$TimerDano.start()

func adicionar_stacks():
	$Timer.start()
	stacks += 1
	print(stacks)
	
func _on_timer_timeout() -> void:
	queue_free()
