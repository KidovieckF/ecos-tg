extends Node2D

var player_dentro = false
var sensor_ja_ativado = false
var portas_da_sala = []
var hud_loja = preload("res://Cenas/Huds/hud_loja.tscn")

func _ready() -> void:
	pass 



func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and player_dentro:
		var hud = hud_loja.instantiate()
		get_parent().add_child(hud)
		print("teste")

func inicar_sala(body):
	if sensor_ja_ativado == false:
		print("Dificuldade: ",RunData.dificuldade)
		if body.is_in_group("Players"):
			sensor_ja_ativado = true
			


func _on_static_body_2d_body_entered(body: Node2D) -> void:
	player_dentro = true


func _on_static_body_2d_body_exited(body: Node2D) -> void:
	player_dentro = false

func ajustar_parede(norte, sul, leste, oeste):
	if norte == true:
		$ParedeNorte.clear()
	if sul == true:
		$ParedeSul.clear()
	if leste == true:
		$ParedeLeste.clear()
	if oeste == true:
		$ParedeOeste.clear()

func _on_area_2d_body_entered(body: Node2D) -> void:
	inicar_sala(body)
