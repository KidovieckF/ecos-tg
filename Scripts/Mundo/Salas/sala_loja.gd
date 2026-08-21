extends Node2D

var player_dentro = false
var sensor_ja_ativado = false
var portas_da_sala = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Interagir") and player_dentro:
		pass

func inicar_sala(body):
	if sensor_ja_ativado == false:
		print("Dificuldade: ",RunData.dificuldade)
		if body.is_in_group("Players"):
			sensor_ja_ativado = true
			
			for p in portas_da_sala:
				print("fechei a porta")
				p.fechar_porta()

func _on_static_body_2d_body_entered(body: Node2D) -> void:
	player_dentro = true


func _on_static_body_2d_body_exited(body: Node2D) -> void:
	player_dentro = false


func _on_area_2d_body_entered(body: Node2D) -> void:
	inicar_sala(body)
