extends CanvasLayer

@export var artefato : Artefato_data

func _ready() -> void:
	get_tree().paused = true

func exibir_artefato(artefato_cena : Artefato_data):
	artefato = artefato_cena
	%Nome.text = artefato.nome
	%Textura.texture = artefato.icone
	%Descricao.text = artefato.descricao

func _process(delta: float) -> void:
	pass


func _on_aceitar_btn_pressed() -> void:
	RunData.adicionar_artefato(artefato)
	get_tree().paused = false
	queue_free()


func _on_recusar_btn_pressed() -> void:
	get_tree().paused = false
	queue_free()
