extends Camera2D

@export var player : CharacterBody2D
var room_size = Vector2(1139,641)

func _physics_process(delta: float) -> void:
	var indice = floor(player.global_position / room_size)
	var canto_superior = indice * room_size
	var centro = canto_superior + (room_size/2)
	global_position = centro
