extends CanvasLayer

var tween_vida

func _physics_process(delta: float) -> void:
	pass
	 
	
func atualizar_vida_boss(valor):
	$ProgressBar.value = valor

func sumir_vida():
	$ProgressBar.visible = false

func abrir_vida_boss(vidaMax):
	$ProgressBar.visible = true
	$ProgressBar.value = 0
	tween_vida = create_tween()
	tween_vida.tween_property($ProgressBar, "value", vidaMax, 2.0)
	
func atualizar_dinheiro():
	%Label.text = "Dinheiro: " + str(RecursosGlobais.dinheiro)
