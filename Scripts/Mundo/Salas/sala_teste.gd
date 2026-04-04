extends Node2D

@export var player: CharacterBody2D

func _ready() -> void:
	player.trocar_camera()
