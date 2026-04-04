extends Node2D

var cena_loja = preload("res://Cenas/Mundo/HUD_loja.tscn")
var player_perto = false
var portas_da_sala = []

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and player_perto:
			print("abriu loja")
			var loja_nova = cena_loja.instantiate()
			get_parent().add_child(loja_nova)

func _on_static_body_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		print("entrou player")
		player_perto = true
		

func ajustar_parede(norte, sul, leste, oeste):
	if norte == true:
		$ParedeNorte.clear()
	if sul == true:
		$ParedeSul.clear()
	if leste == true:
		$ParedeLeste.clear()
	if oeste == true:
		$ParedeOeste.clear()


func _on_static_body_2d_body_exited(body: Node2D) -> void:
	player_perto = false # Replace with function body.
	
func loja():
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		for p in portas_da_sala:
			print("fechei a porta")
			p.abrir_porta()
