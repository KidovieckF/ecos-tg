extends StatusBase

var stacks = 1
var cor = Color.RED
var dano_final = 0
var limite_stacks = 6

func _ready() -> void:
	$TimerDano.start()
	$Timer.start() 

func _physics_process(delta: float) -> void:
	pass
	
func adicionar_stacks(limite, dano_do_fogo):
	limite_stacks = limite
	if stacks > limite:
		stacks = limite
	dano_final = dano_do_fogo
	$Timer.start()
	stacks += 1
	print(stacks)
	
func _on_timer_timeout() -> void:
	queue_free()

func _on_timer_dano_timeout() -> void:
	var dano_fogo_final = dano_final * stacks
	get_parent().take_damage(dano_fogo_final, Color.DARK_RED)
	print("dano queimadura", dano_fogo_final)
	RunData.sinal_dano_queimadura.emit(dano_fogo_final, get_parent())
	$TimerDano.start()
