extends CanvasLayer

var slot_artefato = preload("res://Cenas/Huds/slot_artefato.tscn")

func _ready() -> void:
	RunData.inventario_atualizado.connect(atualizar_inventario)
	atualizar_inventario()
	get_tree().paused = true
	%VidaMax.text = "Vida Máxima: " + str(RunData.vida_max)
	%Dano.text = "Multiplicador de Dano: " + str(RunData.dano_mult_final)
	%Speed.text = "Velocidade: " + str(RunData.speed_calculado)
	%Dificuldade.text = "Dificuldade: " + str(RunData.dificuldade)
	
func _process(delta: float) -> void:
	pass


func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Cenas/Mundo/Menu_inicial.tscn")


func _on_voltar_pressed() -> void:
	get_tree().paused = false
	queue_free()

func atualizar_inventario():
	for child in %InventarioGrid.get_children():
		child.queue_free()
	for artefato in RunData.artefatos_coletados:
		var slot_inventario = slot_artefato.instantiate()
		slot_inventario.tooltip_text = artefato.nome + "\n" + artefato.descricao
		slot_inventario.texture = artefato.icone
		%InventarioGrid.add_child(slot_inventario)
