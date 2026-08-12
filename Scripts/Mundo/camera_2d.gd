extends Camera2D

@export var player : CharacterBody2D
var room_size = Vector2(1139,641)
var forca_tremor = 0.0

func _physics_process(delta: float) -> void:
	var indice = floor(player.global_position / room_size)
	var canto_superior = indice * room_size
	var centro = canto_superior + (room_size/2)
	global_position = centro
	if forca_tremor > 0:
		var forca_tremorx = randf_range(-forca_tremor, forca_tremor)
		var forca_tremory = randf_range(-forca_tremor, forca_tremor)
		offset = Vector2(forca_tremorx, forca_tremory)
		forca_tremor = lerp(forca_tremor, 0.0, 0.05)
	else:
		offset = Vector2.ZERO

func tremor(forca : float):
	forca_tremor = forca
