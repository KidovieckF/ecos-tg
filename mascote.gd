extends CharacterBody2D

@export var player : CharacterBody2D
@export var inimigo : CharacterBody2D
var magia1 = preload("res://Cenas/Player/Mascotes/proj_masc.tscn")
var is_in_range = []
var speed = 300

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	player = get_tree().get_first_node_in_group("Players")
	var direction = (player.global_position - global_position).normalized()
	var distancia = global_position.distance_to(player.global_position)
	if distancia > 50:
		velocity = direction * speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	
	


func _atirar(body):
	var nova_magia = magia1.instantiate()
	get_parent().add_child(nova_magia)
	var direcao_calculada = (body.global_position - global_position).normalized()
	nova_magia.start(global_position, direcao_calculada)
	


func _on_range_body_entered(body: Node2D) -> void:
	if body.is_in_group("Inimigos"):
		print("entrou no range")
		is_in_range.append(body)
		$AtkTimer.start()
			


func _on_range_body_exited(body: Node2D) -> void:
	if body.is_in_group("Inimigos"):
		is_in_range.erase(body)
		


func _on_atk_timer_timeout() -> void:
	var alvo_proximo = null
	var distancia_minima = 99999
	for inimigo in is_in_range:
		var dist = global_position.distance_to(inimigo.global_position)
		if dist < distancia_minima:
			distancia_minima = dist
			alvo_proximo = inimigo
	if alvo_proximo != null:
		_atirar(alvo_proximo)
		
