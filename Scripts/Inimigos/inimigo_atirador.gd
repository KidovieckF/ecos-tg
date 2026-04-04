extends CharacterBody2D

@export var player :CharacterBody2D
@onready var ray = $RayCast2D
@export var cena_item : PackedScene
var flecha = preload("res://Cenas/Inimigos/projetil_ini.tscn")
var vida = 2

var SPEED = 200

func _physics_process(delta: float) -> void:
	if not player:
		player = get_parent().get_node("Player")
	
	if not player:
		return
	var direcao = global_position.direction_to(player.global_position)
	var distancia = global_position.distance_to(player.global_position)
	
	ray.target_position = to_local(player.global_position)
	if ray.is_colliding():
		var quem_bateu = ray.get_collider()
		if quem_bateu == player:
			if distancia > 150:
				velocity = direcao * SPEED
			elif distancia < 100:
				velocity = -direcao * SPEED
			else:
				velocity = Vector2.ZERO
			move_and_slide()
			if $AttackCD.is_stopped():
				atirar()
			
			
func atirar():
	var nova_flecha = flecha.instantiate()
	get_parent().add_child(nova_flecha)
	var direcao_calculada = (player.position - global_position).normalized()
	nova_flecha.start(global_position, direcao_calculada)
	$AttackCD.start()
	
func take_damage(quantidade):
	vida -= quantidade
	print("Inimigo tomou dano! Vida restante: ", vida)
	if vida <= 0:
		morrer()
func morrer():
	spawn_item()
	queue_free()
	
func spawn_item():
	
	var sorteio = randi() % 100
	if sorteio <= 50:
		print("Spawnou")
		var novo_item = cena_item.instantiate()
		novo_item.global_position = global_position
		novo_item.coletado.connect(player.curar)
		get_parent().add_child(novo_item)
		
func _on_attack_cd_timeout() -> void:
	pass # Replace with function body.
