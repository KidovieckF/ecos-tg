

extends Node2D

var portas_da_sala = []
var contador_inimigos = 0
var sensor_ja_ativado = false
var tempo_de_vida = 0
var boss_cena = preload("res://Cenas/Inimigos/boss1.tscn")
var boss_fall = preload("res://Cenas/Inimigos/boss_fall.tscn")

func _ready() -> void:
	pass

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
	if sensor_ja_ativado == false and tempo_de_vida > 0.5:
		print("Detector de sala ativado por: ", body.name)
		if body.is_in_group("Players"):
			for p in portas_da_sala:
				print("fechei a porta")
				p.fechar_porta()
			for i in get_children():
				print("Filho: ", i.name, " Grupos: ", i.get_groups())
				if i.is_in_group("Inimigos"):
					print("Acordando inimigo: ", i.name)
					i.ativo = true
			sensor_ja_ativado = true
		var fall = boss_fall.instantiate()
		fall.position = $SpawnBoss.position
		add_child(fall)
		await get_tree().create_timer(3).timeout
		fall.ativar()
		await get_tree().create_timer(0.2).timeout
		fall.queue_free()
		var boss = boss_cena.instantiate()
		boss.position = $SpawnBoss.position
		add_child(boss)
