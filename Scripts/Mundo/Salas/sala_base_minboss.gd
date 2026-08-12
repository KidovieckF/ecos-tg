extends Node2D

var portas_da_sala = []
var contador_inimigos = 0
var sensor_ja_ativado = false
var tempo_de_vida = 0
var lista_inimigos = []
var round_atual = 1
var round_maximo =  4
var tamanho_onda = 4
var inimigo = preload("res://Cenas/Inimigos/inimigo_base.tscn")
var miniboss = preload("res://Cenas/Inimigos/Miniboss/Miniboss_base.tscn")
var player
var dificuldade = 1
@export var tipos_inimigos : Array[inimigo_data]


func _ready() -> void:
	tamanho_onda =  randi_range(3, 15)

func _physics_process(delta: float) -> void:
	tempo_de_vida += delta

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
	print("SALA: ", name, " | DETECTOU: ", body.name, " | POSIÇÃO DO CORPO: ", body.global_position)
	
	
func inicar_sala(body):
	if sensor_ja_ativado == false and tempo_de_vida > 0.5:
		if body.is_in_group("Players"):
			sensor_ja_ativado = true
			RunData.dificuldade += dificuldade
			print("Dificuldade: ",RunData.dificuldade)
			for p in portas_da_sala:
				print("fechei a porta")
				p.fechar_porta()
			print("Detector de sala ativado por: ", body.name)
			player = body
			await get_tree().create_timer(1.0).timeout
			var miniboss_scene = miniboss.instantiate()
			miniboss_scene.position = $SpawnBoss.position
			add_child(miniboss_scene)
			
