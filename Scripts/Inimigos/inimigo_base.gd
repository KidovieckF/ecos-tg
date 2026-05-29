extends CharacterBody2D

signal morreu
@export var player :CharacterBody2D
@export var cena_item : PackedScene
@export var cena_moeda : PackedScene
@export var data : inimigo_data
var last_direction
var ativo = false
var vida_max
var vida_atual
var ind_dano = preload("res://Cenas/Mundo/Ind_dano.tscn")

func _ready() -> void:
	set_physics_process(true) 
	$CollisionShape2D.set_deferred("disabled",false)
	vida_max = data.vida * player.nivel
	vida_atual = vida_max
	$AreaDano.pegarDano(data.dano)

func _physics_process(delta: float) -> void:
	if player != null:
		
		var direction = (player.global_position - global_position).normalized()
		if direction:
			if direction.x > 0: 
				last_direction = direction
				$Sprite2D.flip_h = false
				$Sprite2D.play("Andando")
			elif direction.x < 0:
				last_direction = direction
				$Sprite2D.flip_h = true
				$Sprite2D.play("Andando")
		velocity = direction * data.speed
		move_and_slide()
		

func take_damage(quantidade, cor = Color.WHITE):
	vida_atual -= quantidade
	#print("Inimigo tomou dano! Vida restante: ", vida)
	var novo_dano = ind_dano.instantiate() 
	get_parent().add_child(novo_dano)
	novo_dano.global_position = global_position
	novo_dano._mostrar_dano(quantidade, cor)
	if vida_atual <= 0:
		morrer()

func morrer():
	#print("1. INIMIGO: Morri e emiti o sinal!")
	set_physics_process(false) 
	$CollisionShape2D.set_deferred("disabled",true)
	$Sprite2D.play("Morrendo")
	await $Sprite2D.animation_finished
	spawn_item()
	queue_free()
	morreu.emit()
	
func spawn_item():
	var sorteio = randi() % 100
	if sorteio <= 50:
		var novo_item = cena_item.instantiate()
		novo_item.position = position
		novo_item.coletado.connect(player.curar)
		get_parent().add_child(novo_item)
		var moeda_nova = cena_moeda.instantiate()
		moeda_nova.position = position
		moeda_nova.coletado.connect(player.coletar_moeda)
		get_parent().add_child(moeda_nova)
		
