extends Control

@export var itens: Array[Texture2D]
var indice = 0

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func _ready() -> void:
	mostrar_item()

func mostrar_item() -> void:
	if itens.size() == 0:
		return
	texture_rect.texture = itens[indice]
	label.text = "%d / %d" % [indice + 1, itens.size()]

func _on_btn_anterior_pressed() -> void:
	indice = wrapi(indice - 1, 0, itens.size())
	mostrar_item()

func _on_btn_proximo_pressed() -> void:
	indice = wrapi(indice + 1, 0, itens.size())
	mostrar_item()
