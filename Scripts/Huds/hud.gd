extends CanvasLayer

var tween_vida
var slot_artefato = preload("res://Cenas/Huds/slot_artefato.tscn")

func _ready() -> void:
	RunData.inventario_atualizado.connect(atualizar_inventario)
	atualizar_inventario()
	
func _physics_process(delta: float) -> void:
	pass
	 
	
func atualizar_xp(xp_atual, xp_barra, nivel):
	%Exp.max_value = xp_barra
	%Exp.value = xp_atual
	%Label.text = str(nivel)
	
func atualizar_vida(vida_atual, vida_barra):
	%Vida.max_value = vida_barra
	%Vida.value = vida_atual
	
	
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
	%Dinheiro.text = "$: " + str(RecursosGlobais.moeda)

func atualizar_inventario():
	for child in %InventarioGrid.get_children():
		child.queue_free()
	for artefato in RunData.artefatos_coletados:
		var slot_inventario = slot_artefato.instantiate()
		
		slot_inventario.texture = artefato.icone
		%InventarioGrid.add_child(slot_inventario)
		
